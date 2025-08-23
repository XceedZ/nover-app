#!/bin/bash

# --- KONFIGURASI ---
RCLONE_REMOTE="gdrive"
GDRIVE_FOLDER_ID="1DGJN4IKPGPeKSCn_Fhna3mZimP-jVjrv"
APP_NAME="nover"
# !!! TAMBAHKAN API KEY ANDA DI SINI !!!
GDRIVE_API_KEY="AIzaSyCgqBm_cWZ2k20nUV_TgW647xYDQYk6Tfk"
# --------------------

# Hentikan script jika terjadi error
set -e

echo "🔍 Membaca versi saat ini dari pubspec.yaml..."
VERSION_STRING=$(yq e '.version' pubspec.yaml | cut -d '+' -f 1)
MAJOR_MINOR=$(echo "$VERSION_STRING" | cut -d. -f1,2)
PATCH_NUMBER=$(echo "$VERSION_STRING" | cut -d. -f3)
NEW_PATCH_NUMBER=$((PATCH_NUMBER + 1))
NEW_VERSION="$MAJOR_MINOR.$NEW_PATCH_NUMBER"

echo "⬆️  Menaikkan versi ke: $NEW_VERSION"
yq e ".version = \"$NEW_VERSION\"" -i pubspec.yaml

echo "📝 Silakan masukkan catatan rilis (release notes). Tekan Ctrl+D saat selesai:"
RELEASE_NOTES=$(cat)

echo "🚀 Memulai proses build Flutter (release APK)..."
flutter build apk --release --dart-define-from-file=.env.production --build-name=$NEW_VERSION --build-number=$NEW_PATCH_NUMBER

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
RENAMED_APK_PATH="build/app/outputs/flutter-apk/${APP_NAME}-v${NEW_VERSION}.apk"
JSON_PATH="build/version.json"

mv "$APK_PATH" "$RENAMED_APK_PATH"
echo "✅ APK berhasil dibuat di: $RENAMED_APK_PATH"

echo "☁️  Mengunggah APK ke Google Drive..."
rclone copy "$RENAMED_APK_PATH" "${RCLONE_REMOTE}:" --drive-root-folder-id="${GDRIVE_FOLDER_ID}" --progress -v --drive-chunk-size 64M --ignore-checksum --drive-upload-cutoff 256M

FILE_ID=$(rclone lsf "${RCLONE_REMOTE}:${APP_NAME}-v${NEW_VERSION}.apk" --drive-root-folder-id="${GDRIVE_FOLDER_ID}" --format "i")

if [ -z "$FILE_ID" ]; then
    echo "❌ Gagal mendapatkan ID file dari Google Drive setelah upload!"
    exit 1
fi

# === PERUBAHAN FORMAT URL MENGGUNAKAN API KEY ===
DOWNLOAD_URL="https://www.googleapis.com/drive/v3/files/${FILE_ID}?alt=media&key=${GDRIVE_API_KEY}"
# ===============================================
echo "🔗 URL Download APK: $DOWNLOAD_URL"

echo "📄 Membuat file version.json..."
ESCAPED_RELEASE_NOTES=$(echo "$RELEASE_NOTES" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\n/\\n/g')

cat > "$JSON_PATH" << EOL
{
  "version": "${NEW_VERSION}",
  "url": "${DOWNLOAD_URL}",
  "release_notes": "${ESCAPED_RELEASE_NOTES}"
}
EOL

echo "☁️  Mengunggah version.json ke Google Drive..."
rclone copyto "$JSON_PATH" "${RCLONE_REMOTE}:version.json" --drive-root-folder-id="${GDRIVE_FOLDER_ID}" --progress

echo "🎉 Proses Selesai! Versi $NEW_VERSION berhasil di-build dan diunggah."