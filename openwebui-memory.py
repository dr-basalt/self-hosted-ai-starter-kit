#!/usr/bin/env python3
"""
Module de mémoire pour OpenWebUI avec Qdrant
Gère la sauvegarde des conversations et la recherche réflexive
"""

import json
import time
from datetime import datetime
from typing import List, Dict, Any, Optional
import requests
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
import numpy as np
from sentence_transformers import SentenceTransformer
import logging

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OpenWebUIMemory:
    def __init__(self, qdrant_host: str = "localhost", qdrant_port: int = 6333):
        """Initialise le système de mémoire avec Qdrant"""
        self.qdrant_client = QdrantClient(host=qdrant_host, port=qdrant_port)
        self.collection_name = "openwebui_memory"
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
        self._init_collection()
    
    def _init_collection(self):
        """Initialise la collection Qdrant si elle n'existe pas"""
        try:
            collections = self.qdrant_client.get_collections()
            if self.collection_name not in [c.name for c in collections.collections]:
                self.qdrant_client.create_collection(
                    collection_name=self.collection_name,
                    vectors_config=VectorParams(
                        size=self.embedding_model.get_sentence_embedding_dimension(),
                        distance=Distance.COSINE
                    )
                )
                logger.info(f"Collection {self.collection_name} créée")
        except Exception as e:
            logger.error(f"Erreur lors de l'initialisation de la collection: {e}")
    
    def save_conversation(self, user_message: str, ai_response: str, 
                         model_used: str = "phi3:3.8b", 
                         session_id: Optional[str] = None) -> bool:
        """Sauvegarde une conversation dans Qdrant"""
        try:
            timestamp = datetime.now().isoformat()
            session_id = session_id or f"session_{int(time.time())}"
            
            # Créer le texte combiné pour l'embedding
            combined_text = f"User: {user_message}\nAI: {ai_response}"
            
            # Générer l'embedding
            embedding = self.embedding_model.encode(combined_text).tolist()
            
            # Préparer les métadonnées
            metadata = {
                "user_message": user_message,
                "ai_response": ai_response,
                "model_used": model_used,
                "session_id": session_id,
                "timestamp": timestamp,
                "combined_text": combined_text
            }
            
            # Créer le point pour Qdrant
            point = PointStruct(
                id=int(time.time() * 1000),  # ID unique basé sur le timestamp
                vector=embedding,
                payload=metadata
            )
            
            # Insérer dans Qdrant
            self.qdrant_client.upsert(
                collection_name=self.collection_name,
                points=[point]
            )
            
            logger.info(f"Conversation sauvegardée pour la session {session_id}")
            return True
            
        except Exception as e:
            logger.error(f"Erreur lors de la sauvegarde: {e}")
            return False
    
    def search_similar_conversations(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Recherche des conversations similaires"""
        try:
            # Générer l'embedding de la requête
            query_embedding = self.embedding_model.encode(query).tolist()
            
            # Rechercher dans Qdrant
            search_result = self.qdrant_client.search(
                collection_name=self.collection_name,
                query_vector=query_embedding,
                limit=limit
            )
            
            # Formater les résultats
            results = []
            for hit in search_result:
                results.append({
                    "score": hit.score,
                    "user_message": hit.payload.get("user_message", ""),
                    "ai_response": hit.payload.get("ai_response", ""),
                    "model_used": hit.payload.get("model_used", ""),
                    "session_id": hit.payload.get("session_id", ""),
                    "timestamp": hit.payload.get("timestamp", "")
                })
            
            return results
            
        except Exception as e:
            logger.error(f"Erreur lors de la recherche: {e}")
            return []
    
    def get_conversation_history(self, session_id: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Récupère l'historique d'une session spécifique"""
        try:
            # Rechercher par session_id
            search_result = self.qdrant_client.scroll(
                collection_name=self.collection_name,
                scroll_filter={"must": [{"key": "session_id", "match": {"value": session_id}}]},
                limit=limit
            )
            
            # Formater les résultats
            results = []
            for hit in search_result[0]:
                results.append({
                    "user_message": hit.payload.get("user_message", ""),
                    "ai_response": hit.payload.get("ai_response", ""),
                    "model_used": hit.payload.get("model_used", ""),
                    "timestamp": hit.payload.get("timestamp", "")
                })
            
            # Trier par timestamp
            results.sort(key=lambda x: x["timestamp"])
            return results
            
        except Exception as e:
            logger.error(f"Erreur lors de la récupération de l'historique: {e}")
            return []
    
    def create_reflective_context(self, current_query: str, session_id: str = None) -> str:
        """Crée un contexte réflexif basé sur l'historique et les conversations similaires"""
        try:
            context_parts = []
            
            # Ajouter l'historique de la session si disponible
            if session_id:
                history = self.get_conversation_history(session_id, limit=5)
                if history:
                    context_parts.append("=== Historique de la conversation ===")
                    for conv in history[-3:]:  # Dernières 3 conversations
                        context_parts.append(f"User: {conv['user_message']}")
                        context_parts.append(f"AI: {conv['ai_response']}")
                    context_parts.append("")
            
            # Ajouter des conversations similaires
            similar = self.search_similar_conversations(current_query, limit=3)
            if similar:
                context_parts.append("=== Conversations similaires ===")
                for conv in similar:
                    context_parts.append(f"User: {conv['user_message']}")
                    context_parts.append(f"AI: {conv['ai_response']}")
                context_parts.append("")
            
            # Ajouter le contexte actuel
            context_parts.append("=== Contexte actuel ===")
            context_parts.append(f"User: {current_query}")
            
            return "\n".join(context_parts)
            
        except Exception as e:
            logger.error(f"Erreur lors de la création du contexte réflexif: {e}")
            return f"User: {current_query}"

# API Flask pour l'intégration avec OpenWebUI
from flask import Flask, request, jsonify

app = Flask(__name__)
memory = OpenWebUIMemory(qdrant_host="qdrant")

@app.route('/memory/save', methods=['POST'])
def save_conversation():
    """Endpoint pour sauvegarder une conversation"""
    data = request.json
    success = memory.save_conversation(
        user_message=data.get('user_message', ''),
        ai_response=data.get('ai_response', ''),
        model_used=data.get('model_used', 'phi3:3.8b'),
        session_id=data.get('session_id')
    )
    return jsonify({"success": success})

@app.route('/memory/search', methods=['POST'])
def search_conversations():
    """Endpoint pour rechercher des conversations similaires"""
    data = request.json
    results = memory.search_similar_conversations(
        query=data.get('query', ''),
        limit=data.get('limit', 5)
    )
    return jsonify({"results": results})

@app.route('/memory/context', methods=['POST'])
def get_reflective_context():
    """Endpoint pour obtenir le contexte réflexif"""
    data = request.json
    context = memory.create_reflective_context(
        current_query=data.get('query', ''),
        session_id=data.get('session_id')
    )
    return jsonify({"context": context})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)
