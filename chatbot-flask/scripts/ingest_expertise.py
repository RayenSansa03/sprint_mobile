import requests
import os
import re

# Configuration
API_URL = "http://localhost:5002/ingest"
API_KEY = "secret_ingest_key"
DOC_PATH = os.path.join(os.path.dirname(__file__), "..", "knowledge_sources", "expertise_maladies_mais.md")

def split_markdown_by_headings(content):
    """Découpe un fichier Markdown en chunks basés sur les titres de niveau 2."""
    sections = re.split(r'\n## ', content)
    chunks = []
    
    # La première section contient souvent le titre principal (H1)
    chunks.append(sections[0].strip())
    
    # Pour les suivantes, on remet le '## ' car re.split l'enlève
    for section in sections[1:]:
        chunks.append(f"## {section.strip()}")
        
    return [c for c in chunks if len(c) > 50] # Filtrer les trop petits segments

def ingest_data():
    if not os.path.exists(DOC_PATH):
        print(f"Erreur : le fichier {DOC_PATH} est introuvable.")
        return

    with open(DOC_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    chunks = split_markdown_by_headings(content)
    print(f"Préparation de l'ingestion de {len(chunks)} sections...")

    payload = {
        "texts": chunks,
        "metadatas": [{"source": "expertise_maladies_mais.md", "type": "corn_expert"}] * len(chunks)
    }

    headers = {
        "X-API-KEY": API_KEY,
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(API_URL, json=payload, headers=headers)
        if response.status_code == 200:
            print(f"Succès ! {response.json().get('ingested')} sections ingérées.")
        else:
            print(f"Erreur API ({response.status_code}) : {response.text}")
            print("\nVérifiez que votre serveur Flask (app.py) est bien lancé sur le port 5002.")
    except Exception as e:
        print(f"Erreur de connexion : {e}")
        print("\nVérifiez que le serveur Flask est démarré.")

if __name__ == "__main__":
    ingest_data()
