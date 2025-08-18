#!/usr/bin/env python3
"""
Script de configuration automatique des modèles OpenWebUI
Configure les modèles avec des paramètres optimisés via l'API OpenWebUI
"""

import requests
import json
import time
import os
from typing import Dict, Any

class OpenWebUIConfigurator:
    def __init__(self, base_url: str = "http://localhost:3000"):
        self.base_url = base_url
        self.session = requests.Session()
        
    def wait_for_service(self, max_retries: int = 30) -> bool:
        """Attendre que le service OpenWebUI soit disponible"""
        print("⏳ Attente du démarrage d'OpenWebUI...")
        for i in range(max_retries):
            try:
                response = self.session.get(f"{self.base_url}/api/version", timeout=5)
                if response.status_code == 200:
                    print("✅ OpenWebUI est prêt!")
                    return True
            except requests.exceptions.RequestException:
                pass
            time.sleep(2)
            print(f"   Tentative {i+1}/{max_retries}...")
        return False
    
    def configure_models(self):
        """Configurer les modèles avec des paramètres optimisés"""
        print("🔧 Configuration des modèles optimisés...")
        
        # Configuration des modèles avec paramètres optimisés
        models_config = {
            "llama2": {
                "name": "llama2",
                "display_name": "Llama 2 (Optimisé)",
                "description": "Modèle Llama 2 optimisé pour la conversation",
                "parameters": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "top_k": 40,
                    "max_tokens": 2048,
                    "repeat_penalty": 1.1,
                    "frequency_penalty": 0.0,
                    "presence_penalty": 0.0
                },
                "context_length": 4096,
                "prompt_template": "<s>[INST] {prompt} [/INST]",
                "stop_sequences": ["</s>", "[INST]", "[/INST]"]
            },
            "phi3": {
                "name": "phi3",
                "display_name": "Phi-3 (Optimisé)",
                "description": "Modèle Phi-3 optimisé pour la créativité",
                "parameters": {
                    "temperature": 0.8,
                    "top_p": 0.95,
                    "top_k": 50,
                    "max_tokens": 4096,
                    "repeat_penalty": 1.05,
                    "frequency_penalty": 0.1,
                    "presence_penalty": 0.1
                },
                "context_length": 8192,
                "prompt_template": "<|user|>\n{prompt}<|end|>\n<|assistant|>",
                "stop_sequences": ["<|end|>", "<|user|>"]
            },
            "gemma2": {
                "name": "gemma2",
                "display_name": "Gemma 2 (Optimisé)",
                "description": "Modèle Gemma 2 optimisé pour la précision",
                "parameters": {
                    "temperature": 0.6,
                    "top_p": 0.85,
                    "top_k": 30,
                    "max_tokens": 3072,
                    "repeat_penalty": 1.15,
                    "frequency_penalty": 0.05,
                    "presence_penalty": 0.05
                },
                "context_length": 6144,
                "prompt_template": "<start_of_turn>user\n{prompt}<end_of_turn>\n<start_of_turn>model\n",
                "stop_sequences": ["<end_of_turn>", "<start_of_turn>"]
            }
        }
        
        # Configuration via l'API OpenWebUI
        for model_name, config in models_config.items():
            try:
                print(f"  📝 Configuration de {model_name}...")
                
                # Créer/Modifier le modèle via l'API
                model_data = {
                    "name": config["name"],
                    "display_name": config["display_name"],
                    "description": config["description"],
                    "parameters": config["parameters"],
                    "context_length": config["context_length"],
                    "prompt_template": config["prompt_template"],
                    "stop_sequences": config["stop_sequences"],
                    "enabled": True
                }
                
                # Endpoint pour créer/modifier un modèle
                response = self.session.post(
                    f"{self.base_url}/api/models",
                    json=model_data,
                    headers={"Content-Type": "application/json"}
                )
                
                if response.status_code in [200, 201]:
                    print(f"    ✅ {model_name} configuré avec succès")
                else:
                    print(f"    ⚠️  {model_name}: {response.status_code} - {response.text}")
                    
            except Exception as e:
                print(f"    ❌ Erreur lors de la configuration de {model_name}: {e}")
    
    def configure_memory_settings(self):
        """Configurer les paramètres de mémoire"""
        print("🧠 Configuration des paramètres de mémoire...")
        
        memory_config = {
            "enabled": True,
            "collection_name": "openwebui_memory",
            "embedding_model": "all-MiniLM-L6-v2",
            "tenant_separator": ":",
            "max_context_length": 8192,
            "similarity_threshold": 0.7,
            "max_results": 10
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/memory/settings",
                json=memory_config,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                print("  ✅ Paramètres de mémoire configurés")
            else:
                print(f"  ⚠️  Configuration mémoire: {response.status_code}")
                
        except Exception as e:
            print(f"  ❌ Erreur configuration mémoire: {e}")
    
    def configure_voice_settings(self):
        """Configurer les paramètres vocaux"""
        print("🎤 Configuration des paramètres vocaux...")
        
        voice_config = {
            "stt_engine": "openai",
            "stt_model": "whisper-1",
            "tts_engine": "openai",
            "tts_model": "tts-1",
            "tts_voice": "alloy",
            "enabled": True
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/voice/settings",
                json=voice_config,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                print("  ✅ Paramètres vocaux configurés")
            else:
                print(f"  ⚠️  Configuration vocale: {response.status_code}")
                
        except Exception as e:
            print(f"  ❌ Erreur configuration vocale: {e}")

def main():
    """Fonction principale"""
    print("🚀 Configuration automatique d'OpenWebUI")
    print("=" * 50)
    
    # Récupérer l'URL depuis les variables d'environnement ou utiliser la valeur par défaut
    base_url = os.getenv("OPENWEBUI_URL", "http://localhost:3000")
    
    configurator = OpenWebUIConfigurator(base_url)
    
    # Attendre que le service soit prêt
    if not configurator.wait_for_service():
        print("❌ Impossible de se connecter à OpenWebUI")
        return False
    
    # Configurer les modèles
    configurator.configure_models()
    
    # Configurer la mémoire
    configurator.configure_memory_settings()
    
    # Configurer les paramètres vocaux
    configurator.configure_voice_settings()
    
    print("\n✅ Configuration terminée!")
    print(f"🌐 Accédez à OpenWebUI: {base_url}")
    print("🔑 Connectez-vous avec les identifiants par défaut")
    
    return True

if __name__ == "__main__":
    main()
