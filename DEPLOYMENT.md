# Flutter Deploy Scripts

Zestaw skryptów do automatycznego deploymentu aplikacji Flutter na wszystkie platformy.

## 📦 Dostępne skrypty

### 1. **deploy.sh** - Pełny deployment z menu
Interaktywny skrypt z wyborem platformy i opcji deploymentu.

**Użycie:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Funkcje:**
- ✅ Automatyczne zwiększanie wersji (build number)
- ✅ Czyszczenie cache (`flutter clean`)
- ✅ Pobieranie zależności (`flutter pub get`)
- ✅ Budowanie Web (z opcją Firebase deploy)
- ✅ Budowanie Android (APK lub App Bundle)
- ✅ Budowanie iOS (z instrukcjami do Xcode)
- ✅ Menu pozwalające wybrać platformy
- ✅ Kolorowe komunikaty i progress

### 2. **quick-deploy.sh** - Szybki deploy Web
Automatyczny deploy web na Firebase - bez żadnych pytań.

**Użycie:**
```bash
chmod +x quick-deploy.sh
./quick-deploy.sh
```

**Funkcje:**
- ✅ Zwiększenie wersji
- ✅ Flutter clean & pub get
- ✅ Build web
- ✅ Firebase deployment

## 🚀 Pierwsze uruchomienie

### 1. Uczynienie skryptów executable
```bash
chmod +x deploy.sh quick-deploy.sh
```

### 2. Instalacja Firebase CLI (jeśli chcesz deployować web)
```bash
npm install -g firebase-tools
firebase login
```

## 📋 Procedura deploymentu

### Opcja A: Pełny deployment (wszystkie platformy)
```bash
./deploy.sh
# Wybierz opcję 4 (Wszystkie)
```

### Opcja B: Szybki web deploy
```bash
./quick-deploy.sh
```

### Opcja C: Tylko clean & pub get
```bash
./deploy.sh
# Wybierz opcję 5
```

## 🔄 Co skrypty robią

1. **Aktualizacja wersji**
   - Automatycznie zwiększa build number w `pubspec.yaml`
   - Lub pozwala ręcznie wpisać nową wersję

2. **Czyszczenie** (`flutter clean`)
   - Usuwa wszystkie artefakty build
   - Czyści cache Dart
   - **Ważne dla uniknięcia problemów z cachowaniem!**

3. **Pobieranie zależności** (`flutter pub get`)
   - Pobiera wszystkie pakiety zadeklarowane w pubspec.yaml

4. **Build na wybranej platformie**
   - **Web**: Tworzy optimized build w `build/web/`
   - **Android**: APK lub App Bundle w `build/app/outputs/`
   - **iOS**: Przygotowuje build do Xcode Archive

5. **Firebase deployment** (tylko web)
   - Wysyła pliki na Firebase Hosting
   - Automatycznie publikuje nową wersję

## 🐛 Rozwiązywanie problemów

### Skrypt nie ma uprawnień do wykonania
```bash
chmod +x deploy.sh quick-deploy.sh
```

### Firebase login nie działa
```bash
firebase login --no-localhost
```

### Błąd: "pubspec.yaml nie znaleziony"
- Uruchom skrypt z głównego katalogu projektu (gdzie jest `pubspec.yaml`)

### Problemy z cachowaniem aplikacji u użytkowników
- Zawsze uruchamiaj `flutter clean` przed buildem
- Skrypty to robią automatycznie
- Zaktualizuj Firebase cache headers (patrz `firebase.json`)

## 📝 Konfiguracja Firebase cache (opcjonalnie)

Edytuj `firebase.json` aby ustawić odpowiednie cache headery:

```json
{
  "hosting": {
    "public": "build/web",
    "headers": [
      {
        "source": "**/*.@(js|css|wasm)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000, immutable"
          }
        ]
      },
      {
        "source": "index.html",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      }
    ]
  }
}
```

## 💡 Szybkie porady

- **Web deploy**: `./quick-deploy.sh` (najszybciej)
- **Android do testowania**: APK
- **Android do Play Store**: App Bundle
- **iOS**: Musisz użyć Xcode do finalnego publishu
- **Zawsze rób flutter clean** przed buildowaniem (skrypty to robią!)

## ✨ Przykładowy flow deploymentu

```bash
# Robocie zmian w kodzie
# ...
# Jesteście gotowi do deploymentu?

./deploy.sh
# ✓ Wersja zmieniona: 1.0.0+1 → 1.0.0+2
# ✓ flutter clean
# ✓ flutter pub get
# Wybierz: 1 (Web)
# ✓ flutter build web --release
# Pytanie: Deploy na Firebase? y
# ✓ firebase deploy --only hosting
# ✓ GOTOWE!

# Teraz Twoi użytkownicy zobaczą nową wersję!
```

---

**Autor**: Deployment Automation  
**Projekt**: flutter_application_1
