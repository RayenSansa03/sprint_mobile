# ============================================================
# graph/graph_builder.py — Construction du graphe LangGraph
# Assemble tous les agents en un StateGraph compilé et exécutable.
# ============================================================

from langgraph.graph import StateGraph, START, END

from state import AgriSmartState
from agents.router_agent import router_node
from agents.guide_agent import guide_node
from agents.db_agent import db_agent_node
from agents.answer_db_agent import answer_db_node
from agents.info_agent import info_node, fallback_node
from tools.mcp_tool import mcp_tool_node


def _route_intent(state: AgriSmartState) -> str:
    """
    Fonction de routage conditionnel du graphe.

    Lit le champ 'intent' du state (rempli par router_node) et retourne
    le nom du prochain nœud à activer.

    Mapping :
    - "guide_ui"  → "guide_node"
    - "query_db"  → "db_agent_node"
    - "info_agri" → "info_node"
    - tout autre  → "fallback_node"

    Returns:
        str: Nom du nœud suivant dans le graphe.
    """
    intent    = state.get("intent", "unknown")
    user_role = state.get("user_role", "visiteur")

    if intent == "guide_ui":
        return "guide_node"
    elif intent == "query_db":
        return "db_agent_node"
    elif intent == "info_agri":
        return "info_node"
    else:
        return "fallback_node"


def build_graph():
    """
    Construit et compile le graphe LangGraph multi-agents d'AgriSmart.

    Topologie du graphe :

        START
          │
          ▼
      router_node  ← classifie l'intention
          │
          ├── "guide_ui"  ──→ guide_node      ──→ END
          │
          ├── "query_db"  ──→ db_agent_node
          │                       │
          │                  mcp_tool_node  ← envoie POST au MCP server (port 5001)
          │                       │
          │                  answer_db_node ──→ END
          │
          ├── "info_agri" ──→ info_node      ──→ END
          └── (autre)     ──→ fallback_node  ──→ END

    Returns:
        CompiledGraph: Graphe LangGraph compilé, prêt à être invoqué.
    """
    graph = StateGraph(AgriSmartState)

    # ── Enregistrement de tous les nœuds ────────────────────
    graph.add_node("router_node",      router_node)
    graph.add_node("guide_node",       guide_node)
    graph.add_node("db_agent_node",   db_agent_node)
    graph.add_node("mcp_tool_node",   mcp_tool_node)
    graph.add_node("answer_db_node",  answer_db_node)
    graph.add_node("info_node",        info_node)
    graph.add_node("fallback_node",    fallback_node)

    # ── Arête d'entrée ───────────────────────────────────────
    graph.add_edge(START, "router_node")

    # ── Arête conditionnelle : router → branchement ─────────
    graph.add_conditional_edges(
        "router_node",
        _route_intent,
        {
            "guide_node":    "guide_node",
            "db_agent_node": "db_agent_node",
            "info_node":     "info_node",
            "fallback_node": "fallback_node",
        },
    )


    # ── Arêtes de fin (nœuds terminaux simples) ─────────────
    graph.add_edge("guide_node",    END)
    graph.add_edge("info_node",     END)
    graph.add_edge("fallback_node", END)

    # ── Chaîne de traitement base de données ─────────────────
    # db_agent génère le filtre → mcp_tool envoie au MCP server → answer_db reformule → END
    graph.add_edge("db_agent_node",  "mcp_tool_node")
    graph.add_edge("mcp_tool_node",  "answer_db_node")
    graph.add_edge("answer_db_node", END)

    # Compilation du graphe (validation de la topologie + optimisation)
    compiled_graph = graph.compile()

    return compiled_graph
