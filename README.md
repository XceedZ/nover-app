# 📖 Nover - A Novel Mobile App

Nover adalah aplikasi mobile berbasis Flutter yang menawarkan pengalaman membaca novel dari berbagai genre, kapan saja dan di mana saja.

---

## 🚀 Getting Started

### Persyaratan:

* Flutter SDK (Versi terbaru atau sesuai dengan project)
* Android Studio / VS Code / IDE lain yang mendukung Flutter
* Emulator atau perangkat fisik untuk testing

---

## 🏗️ Project Structure

```
lib/
  └── src/
  └── main.dart
.env.development
.env.production
pubspec.yaml
```

* **`.env.development`** → Konfigurasi environment untuk development
* **`.env.production`** → Konfigurasi environment untuk production

---

## 🧪 Menjalankan Aplikasi

### 📌 Development Mode

Jalankan aplikasi dengan environment development:

```bash
flutter run --dart-define-from-file=.env.development
```

---

### 📌 Production Mode (Release Build)

Untuk build dan menjalankan dengan konfigurasi production (release):

```bash
flutter run --dart-define-from-file=.env.production --release
```

Atau untuk build APK/IPA production:

```bash
flutter build apk --dart-define-from-file=.env.production --release
```

---

### 📌 Production Profile Mode (Untuk Testing Performance)

Jika ingin menjalankan dengan konfigurasi production tetapi tetap bisa debug performance (tanpa full release):

```bash
flutter run --dart-define-from-file=.env.production --profile
```

---

## ✅ Tips Tambahan

* Pastikan file `.env.development` dan `.env.production` sudah berada di root project.
* Contoh isi file `.env.development`:

```
API_BASE_URL=https://api-dev.noversystem.com
APP_ENV=development
```

* Contoh isi file `.env.production`:

```
API_BASE_URL=https://api.noversystem.com
APP_ENV=production
```

* Menggunakan package `flutter_dotenv` atau `flutter_config` atau `dart-define` di dalam `pubspec.yaml` untuk membaca variabel.

---

## 📚 Referensi Flutter

* [Flutter Codelab](https://docs.flutter.dev/get-started/codelab)
* [Flutter Cookbook](https://docs.flutter.dev/cookbook)
* [Flutter Dart-define](https://docs.flutter.dev/tools/cli#dart-define)

---

## 👨‍💻 Author

* AlexanderA