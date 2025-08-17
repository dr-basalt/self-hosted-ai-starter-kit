#!/usr/bin/env python3
"""
Script de configuration automatique pour OpenWebUI
Configure les paramètres STT/TTS et autres fonctionnalités
"""

import os
import sys
import json
import sqlite3
from pathlib import Path

def configure_openwebui():
    """Configure OpenWebUI avec les paramètres optimaux"""
    
    # Chemin vers la base de données OpenWebUI
    db_path = "/app/open-webui/data/webui.db"
    
    if not os.path.exists(db_path):
        print(f"Base de données non trouvée: {db_path}")
        return False
    
    try:
        # Connexion à la base de données
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Configuration des paramètres STT/TTS
        configs = [
            # Permissions utilisateur
            ("USER_PERMISSIONS_CHAT_STT", "True"),
            ("USER_PERMISSIONS_CHAT_TTS", "True"),
            ("USER_PERMISSIONS_CHAT_CALL", "True"),
            
            # Configuration STT (Speech-to-Text)
            ("AUDIO_STT_ENGINE", "whisper"),
            ("AUDIO_STT_MODEL", "base"),
            ("AUDIO_STT_SUPPORTED_CONTENT_TYPES", "audio/wav,audio/mp3,audio/m4a,audio/webm"),
            
            # Configuration TTS (Text-to-Speech)
            ("AUDIO_TTS_ENGINE", "openai"),
            ("AUDIO_TTS_MODEL", "tts-1"),
            ("AUDIO_TTS_VOICE", "alloy"),
            ("AUDIO_TTS_SPLIT_ON", "punctuation"),
            
            # Configuration HTTPS
            ("ENABLE_HTTPS", "true"),
            ("SSL_CERT_FILE", "/app/certs/cert.pem"),
            ("SSL_KEY_FILE", "/app/certs/key.pem"),
            
            # Configuration CORS pour HTTPS
            ("CORS_ALLOW_ORIGIN", "*"),
            ("CORS_ALLOW_CREDENTIALS", "true"),
            
            # Configuration générale
            ("ENABLE_SIGNUP", "true"),
            ("ENABLE_LOGIN_FORM", "true"),
            ("ENABLE_OAUTH_GOOGLE", "false"),
            ("ENABLE_OAUTH_GITHUB", "false"),
            ("ENABLE_OAUTH_DISCORD", "false"),
        ]
        
        # Insertion ou mise à jour des configurations
        for key, value in configs:
            cursor.execute("""
                INSERT OR REPLACE INTO config (key, value, updated_at)
                VALUES (?, ?, datetime('now'))
            """, (key, value))
        
        # Configuration des paramètres utilisateur par défaut
        user_settings = {
            "audio_stt_enabled": True,
            "audio_tts_enabled": True,
            "audio_stt_engine": "whisper",
            "audio_tts_engine": "openai",
            "audio_tts_voice": "alloy",
            "audio_tts_model": "tts-1",
        }
        
        # Mise à jour des paramètres utilisateur
        cursor.execute("""
            UPDATE user_settings 
            SET settings = ? 
            WHERE user_id = (SELECT id FROM users LIMIT 1)
        """, (json.dumps(user_settings),))
        
        # Validation des changements
        conn.commit()
        print("✅ Configuration OpenWebUI terminée avec succès!")
        print("📝 Paramètres configurés:")
        for key, value in configs:
            print(f"   - {key}: {value}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors de la configuration: {e}")
        return False
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    success = configure_openwebui()
    sys.exit(0 if success else 1)
