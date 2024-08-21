#!/bin/bash

# Installation des dépendances frontend
echo "Installing frontend dependencies..."
npm install

# Installation de Tailwind CSS
echo "Installing Tailwind CSS..."
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

# Configuration de Tailwind
echo "Configuring Tailwind CSS..."
sed -i "" "s/content: \[\]/content: \[\"\.\/src\/\*\*\/\*\.{vue,js,ts,jsx,tsx}\"\]/g" tailwind.config.js

echo "@tailwind base;" > src/assets/tailwind.css
echo "@tailwind components;" >> src/assets/tailwind.css
echo "@tailwind utilities;" >> src/assets/tailwind.css

# Ajout de Tailwind dans main.js
sed -i "" "s/import App from '\.\/App\.vue';/import App from '.\/App.vue';\nimport '.\/assets\/tailwind.css';/g" src/main.js

echo "Frontend setup complete!"
