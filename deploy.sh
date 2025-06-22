#!/bin/bash

# Flutter 웹 빌드
echo "Building Flutter web app..."
export PATH="$PATH:/Users/ym/flutter/bin"
flutter build web --release --base-href "/photobooth-afterschool/"

# gh-pages 브랜치로 배포
echo "Deploying to gh-pages branch..."
cd build/web
git init
git add .
git commit -m "Deploy Flutter web app"
git branch -M gh-pages
git remote rm origin 2>/dev/null || true
git remote add origin https://github.com/ymdev2023/photobooth-afterschool.git
git push -f origin gh-pages

echo "Deployment complete! Check https://ymdev2023.github.io/photobooth-afterschool/"
