# ============================================================
# state.py — Définition de l'état partagé entre tous les agents
# Utilise TypedDict pour que LangGraph puisse gérer le schéma
# ============================================================

from typing import TypedDict, Optional, Any, List


class AgriSmartState(TypedDict):
    """
    État global partagé et transmis entre tous les nœuds du graphe LangGraph.

    Champs identité :
    - user_id        : identifiant MongoDB de l'utilisateur (ObjectId string)
    - user_role      : rôle utilisateur (détermine droits d'accès)
    - user_query     : question brute de l'utilisateur

    Champs pipeline :
    - intent         : intention détectée par router_agent
    - resolved_intent: intention après résolution (peut différer si re-routé)
    - mongo_query    : {collection, filter, projection} généré par db_agent
    - mongo_result   : liste de documents retournée par MongoDB
    - final_response : réponse finale à renvoyer à l'utilisateur
    - error          : message d'erreur éventuel (None si tout OK)

    Champs contexte conversation :
    - conversation_history : liste de {role, content} des échanges précédents
    - language         : langue détectée ("fr" par défaut)
    """

    # Identité utilisateur
    user_id:    str
    user_email: str       # email de l'utilisateur (utilisé pour filtrer les collections par ownerEmail)
    user_role:  str       # visiteur | admin | agriculteur | cooperative | etat | technicien | ong
    user_query: str

    # Pipeline agents
    diagnostic_context: Optional[str]
    intent:           str           # guide_ui | query_db | info_agri | unknown
    resolved_intent:  Optional[str] # intent après éventuelle correction
    mongo_query:      Optional[dict]
    mongo_result:     Optional[list]
    final_response:   str
    error:            Optional[str]

    # Contexte conversation multi-tour
    conversation_history: Optional[List[dict]]  # [{role: "user"|"assistant", content: "..."}]
    language:             Optional[str]         # "fr" | "ar" | "en"
