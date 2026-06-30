#!/data/data/com.termux/files/usr/bin/bash

clear
echo "=========================="
echo "      VINZ APK BUILDER"
echo "=========================="

read -p "Nama APK        : " APPNAME
read -p "Package ID      : " PACKAGE
read -p "URL Website     : " URL
read -p "Path Logo PNG   : " ICON

echo ""
echo "Mengubah nama aplikasi..."

sed -i "s#<string name=\"app_name\">.*</string>#<string name=\"app_name\">$APPNAME</string>#g" \
android/app/src/main/res/values/strings.xml

echo "Mengubah URL..."

cat > capacitor.config.json <<EOF
{
  "appId": "$PACKAGE",
  "appName": "$APPNAME",
  "webDir": "www",
  "server": {
    "url": "$URL",
    "cleartext": false
  }
}
EOF

echo "Selesai tahap 1."
echo ""
echo "Mengubah Package ID..."

OLD_PACKAGE=$(grep '"appId"' capacitor.config.json.bak 2>/dev/null | cut -d'"' -f4)

if [ -z "$OLD_PACKAGE" ]; then
  OLD_PACKAGE="com.vinzstore.app"
fi

find android -type f \( -name "*.java" -o -name "*.kt" -o -name "*.xml" -o -name "*.gradle" -o -name "*.json" \) \
-exec sed -i "s/$OLD_PACKAGE/$PACKAGE/g" {} \;

OLD_PATH=$(echo "$OLD_PACKAGE" | tr '.' '/')
NEW_PATH=$(echo "$PACKAGE" | tr '.' '/')

if [ -d "android/app/src/main/java/$OLD_PATH" ]; then
    mkdir -p "android/app/src/main/java/$(dirname "$NEW_PATH")"
    mv "android/app/src/main/java/$OLD_PATH" "android/app/src/main/java/$NEW_PATH"
fi

cp capacitor.config.json capacitor.config.json.bak

echo "Package ID berhasil diubah."
echo ""
echo "Mengubah struktur package..."

OLD_PATH="android/app/src/main/java/com/vinzstore/app"

PART1=$(echo $PACKAGE | cut -d. -f2)
PART2=$(echo $PACKAGE | cut -d. -f3)

NEW_PATH="android/app/src/main/java/com/$PART1/$PART2"

mkdir -p "$NEW_PATH"

mv "$OLD_PATH/MainActivity.java" "$NEW_PATH/MainActivity.java"

sed -i "s/package com.vinzstore.app;/package $PACKAGE;/g" \
"$NEW_PATH/MainActivity.java"

sed -i "s/com.vinzstore.app/$PACKAGE/g" \
android/app/build.gradle

sed -i "s/com.vinzstore.app/$PACKAGE/g" \
capacitor.config.json

sed -i "s/com.vinzstore.app/$PACKAGE/g" \
android/app/src/main/AndroidManifest.xml

rm -rf android/app/src/main/java/com/vinzstore

echo "Package berhasil diganti."
