# ============================================================
# agents/info_agent.py — Agent d'information agricole (RAG)
# Effectue une recherche vectorielle dans la base de connaissance
# Chroma et répond exclusivement à partir des documents trouvés.
# ============================================================

import os

from langchain_core.messages import SystemMessage, HumanMessage

from state import AgriSmartState
from config import get_llm, VECTORSTORE_PATH


# Template du prompt système — injecté avec les documents récupérés
SYSTEM_PROMPT_TEMPLATE = """
Tu es AgriSmart Expert, un conseiller agricole professionnel au service des utilisateurs.
Rôle de l'utilisateur : {user_role}

Contexte documentaire disponible :
{retrieved_docs}

CONSIGNES :
1. Réponds UNIQUEMENT à partir des documents fournis ci-dessus.
2. Si les documents permettent une réponse partielle, donne-la avec les nuances nécessaires.
3. Si aucun document ne couvre la question, dis :
   "Je n'ai pas cette information dans ma base de connaissance AgriSmart.
    Pour des conseils personnalisés, consultez votre technicien agricole."
4. Ne génère PAS d'informations phytosanitaires, de dosages ou de recommandations
   de traitement sans source documentaire explicite.
31. Si un diagnostic est présent ({diagnostic}), commence par expliquer cette maladie spécifiquement.
32. Cite le document source entre crochets [Document 1] quand pertinent.
33. Adapte le niveau technique au rôle : agriculteur (pratique), technicien (précis).
""".strip()

# Cache singleton du vectorstore — évite de recharger Chroma à chaque appel
_vectorstore_cache = None


def _get_vectorstore():
    """
    Retourne le vectorstore Chroma (singleton mis en cache pour performance).
    Évite de réinstancier Chroma à chaque appel (coûteux en I/O).
    """
    global _vectorstore_cache
    if _vectorstore_cache is not None:
        return _vectorstore_cache
    from langchain_community.vectorstores import Chroma
    from langchain_huggingface import HuggingFaceEmbeddings
    from config import VECTORSTORE_PATH, EMBEDDING_MODEL_NAME

    # Utilisation d'embeddings locaux gratuits
    embedding_fn = HuggingFaceEmbeddings(model_name=EMBEDDING_MODEL_NAME)

    # Résolution du chemin absolu
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    vs_path = os.path.join(base_dir, VECTORSTORE_PATH)

    # Création du répertoire si absent (première utilisation)
    os.makedirs(vs_path, exist_ok=True)

    _vectorstore_cache = Chroma(
        persist_directory=vs_path,
        embedding_function=embedding_fn,
    )
    return _vectorstore_cache


def info_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud d'information agricole (RAG) : recherche les 4 chunks les plus pertinents
    dans le vectorstore Chroma et génère une réponse basée exclusivement sur ces documents.
    Le rôle utilisateur est injecté pour adapter le niveau de réponse.
    

    Retourne le state enrichi avec le champ 'final_response'.
    """
    # ── Recherche vectorielle ────────────────────────────────
    retrieved_docs_str = ""

    try:
        vectorstore = _get_vectorstore()

        # Construction de la requête de recherche : on mélange la question et le diagnostic
        diagnostic = state.get("diagnostic_context")
        search_query = state["user_query"]
        if diagnostic:
            search_query = f"Maladie {diagnostic} : {search_query}"

        # Recherche des 4 chunks les plus proches sémantiquement
        docs = vectorstore.similarity_search(search_query, k=4)

        if not docs:
            retrieved_docs_str = "Aucun document pertinent trouvé dans la base de connaissance."
        else:
            # Concaténation des contenus avec séparateurs et métadonnées source
            chunks = []
            for i, doc in enumerate(docs, start=1):
                source = doc.metadata.get("source", "source inconnue")
                chunks.append(f"[Document {i} — {source}]\n{doc.page_content}")
            retrieved_docs_str = "\n\n---\n\n".join(chunks)

    except Exception as e:
        # Si le vectorstore est vide ou inaccessible, on continue sans documents
        retrieved_docs_str = (
            "Aucun document disponible dans la base de connaissance "
            f"(erreur de chargement : {str(e)})."
        )

    # ── Appel LLM avec les documents récupérés ───────────────
    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(
        user_role=state.get("user_role", "utilisateur"),
        retrieved_docs=retrieved_docs_str,
        diagnostic=state.get("diagnostic_context", "aucun"),
    )

    llm = get_llm()
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=state["user_query"]),
    ]

    try:
        response = llm.invoke(messages)
        final_response = response.content.strip()
    except Exception as e:
        return {
            **state,
            "final_response": "Erreur lors de la génération de la réponse informative.",
            "error": str(e),
        }

    return {**state, "final_response": final_response}


def fallback_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud de repli intelligent : activé pour les messages 'unknown'
    (messages sociaux, requêtes hors domaine, salutations...).
    Génère une réponse contextuelle via LLM au lieu d'un message générique.
    """
    llm = get_llm()
    user_query = state.get("user_query", "")
    user_role  = state.get("user_role", "utilisateur")

    system_prompt = f"""
Tu es AgriSmart Assistant, un assistant agricole intelligent et bienveillant.
Rôle de l'utilisateur : {user_role}

L'utilisateur t'a envoyé un message qui ne correspond pas à une requête de données
ou de navigation précise.

COMPORTEMENT :
- Si c'est une salutation (bonjour, salut) → réponds chaleureusement et propose 3 exemples
  de ce que tu peux faire selon son rôle.
- Si c'est un remerciement (merci, super) → réponds naturellement et propose une suite.
- Si c'est une question hors sujet → redirige poliment vers les capacités AgriSmart.
- Ne dis JAMAIS "je ne peux pas traiter cette demande".
- Réponds TOUJOURS avec une proposition concrète.
- Maximum 3 phrases.

Exemples de capacités selon le rôle {user_role} :
agriculteur → "voir mes parcelles", "état de mes stocks", "mes prochaines tâches"
visiteur    → "explorer le marketplace", "créer un compte", "découvrir AgriSmart"
admin       → "voir les utilisateurs", "état du système", "rapports"
""".strip()

    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=user_query),
    ]

    try:
        response = llm.invoke(messages)
        return {**state, "final_response": response.content.strip()}
    except Exception:
        return {
            **state,
            "final_response": (
                "Bonjour ! Je suis AgriSmart Assistant. "
                "Je peux vous aider à consulter vos données agricoles, "
                "naviguer dans l'application ou répondre à vos questions sur l'agriculture. "
                "Que puis-je faire pour vous ?"
            ),
        }
