# Guide pour contourner l'avertissement SSL dans votre navigateur

## 🔐 Problème SSL auto-signé

Votre Self-Hosted AI Starter Kit utilise un **certificat SSL auto-signé** pour HTTPS. C'est normal et sécurisé pour un usage privé, mais les navigateurs affichent un avertissement de sécurité.

## 🌐 Accès à OpenWebUI

**URL principale :** `https://taz.infra.ori3com.cloud`

## 🔧 Instructions par navigateur

### Chrome / Edge / Chromium

1. **Accédez à :** `https://taz.infra.ori3com.cloud`
2. **Vous verrez :** "La connexion de ce site n'est pas sécurisée"
3. **Cliquez sur :** "Avancé" (en bas à gauche)
4. **Cliquez sur :** "Continuer vers taz.infra.ori3com.cloud (non sécurisé)"
5. **Optionnel :** Pour éviter l'avertissement à chaque fois :
   - Cliquez sur le cadenas 🔒 dans la barre d'adresse
   - Cliquez sur "Certificat"
   - Cliquez sur "Voir le certificat"
   - Cliquez sur "Installer le certificat"
   - Suivez les instructions pour l'installer

### Firefox

1. **Accédez à :** `https://taz.infra.ori3com.cloud`
2. **Vous verrez :** "Attention : Risque de sécurité potentiel"
3. **Cliquez sur :** "Avancé"
4. **Cliquez sur :** "Accepter le risque et continuer"
5. **Optionnel :** Pour éviter l'avertissement :
   - Cliquez sur "Voir les détails"
   - Cliquez sur "Comprendre les risques"
   - Cliquez sur "Ajouter une exception"
   - Cliquez sur "Confirmer l'exception de sécurité"

### Safari

1. **Accédez à :** `https://taz.infra.ori3com.cloud`
2. **Vous verrez :** "Ce site web n'est pas sécurisé"
3. **Cliquez sur :** "Afficher les détails"
4. **Cliquez sur :** "Visiter ce site web"
5. **Confirmez** en cliquant sur "Visiter ce site web"

### Mobile (Chrome/Safari)

1. **Accédez à :** `https://taz.infra.ori3com.cloud`
2. **Cliquez sur :** "Avancé" ou "Détails"
3. **Cliquez sur :** "Continuer" ou "Visiter le site"

## ✅ Vérification du bon fonctionnement

Une fois l'avertissement contourné, vous devriez voir :

- **OpenWebUI** : Interface de chat avec IA
- **Modèles disponibles** : Llama2, Phi-3, Gemma2
- **Fonctionnalités** : Chat textuel, mémoire persistante
- **URL sécurisée** : `https://taz.infra.ori3com.cloud` (avec cadenas barré)

## 🔐 Pourquoi cet avertissement ?

- **Certificat auto-signé** : Généré localement, pas par une autorité de certification
- **Sécurité** : Le trafic est chiffré, mais le certificat n'est pas "officiel"
- **Normal** : Comportement attendu pour les certificats auto-signés

## 🌟 Solution permanente : Let's Encrypt

Pour éliminer définitivement l'avertissement :

1. **Configurez le DNS** : `taz.infra.ori3com.cloud` → `135.181.25.208`
2. **Exécutez :** `./setup-ssl.sh` sur le serveur
3. **Résultat :** Certificat SSL valide et reconnu par tous les navigateurs

## 📋 Services disponibles

- **OpenWebUI** : `https://taz.infra.ori3com.cloud`
- **N8N** : `http://taz.infra.ori3com.cloud:5678`
- **Ollama API** : `http://taz.infra.ori3com.cloud:11434`
- **Qdrant** : `http://taz.infra.ori3com.cloud:6333`

## 🆘 En cas de problème

Si vous ne pouvez pas accéder au site :

1. **Vérifiez l'URL** : `https://taz.infra.ori3com.cloud` (pas http)
2. **Videz le cache** du navigateur
3. **Testez en navigation privée**
4. **Contactez l'administrateur** si le problème persiste

---

**🎉 Une fois l'avertissement contourné, vous pourrez utiliser OpenWebUI en toute sécurité !**
