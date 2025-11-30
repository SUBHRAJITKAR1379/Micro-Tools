#!/bin/bash

echo "🥛 Smart-Check Quick Start"
echo "=========================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

echo "✅ Node.js $(node --version) detected"
echo ""

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd web
npm install

if [ $? -eq 0 ]; then
    echo "✅ Frontend dependencies installed"
else
    echo "❌ Failed to install frontend dependencies"
    exit 1
fi

echo ""
echo "🚀 Starting development server..."
echo ""
echo "Visit: http://localhost:5173"
echo "Press Ctrl+C to stop"
echo ""

npm run dev
