import json
from langchain_core.messages import SystemMessage, HumanMessage
import os
import sys

# Setup environment
sys.path.insert(0, r"c:\Users\rayen\cert\SprintWeb-main\chatbot-flask\agrismart_agents")
from agents.router_agent import router_node
from state import AgriSmartState

state = {
    "user_query": "Expliquez-moi plus sur la maladie : Rouille Commune du Maïs",
    "user_role": "agriculteur"
}

print("Testing Router Agent...")
from langchain_core.messages import SystemMessage, HumanMessage
import os

from agents.router_agent import SYSTEM_PROMPT_TEMPLATE
from config import get_llm

llm = get_llm()
prompt = SYSTEM_PROMPT_TEMPLATE.format(user_role=state["user_role"])
messages = [SystemMessage(content=prompt), HumanMessage(content=state["user_query"])]
response = llm.invoke(messages)
content = response.content.strip()
# print(f"DEBUG ROUTER: {content}") # Log interne debugger

result = router_node(state)
print(f"Detected Intent: {result['intent']}")
