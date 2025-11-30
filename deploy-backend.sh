#!/bin/bash

echo "☁️  Smart-Check Backend Deployment"
echo "==================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo "❌ AWS SAM CLI is not installed. Please install it first."
    echo "Visit: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    exit 1
fi

echo "✅ AWS CLI detected"
echo "✅ SAM CLI detected"
echo ""

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install backend dependencies"
    exit 1
fi

echo "✅ Backend dependencies installed"
echo ""

# Build with SAM
echo "🔨 Building with SAM..."
sam build

if [ $? -ne 0 ]; then
    echo "❌ SAM build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Deploy
echo "🚀 Deploying to AWS..."
echo ""
sam deploy --guided

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "Next steps:"
    echo "1. Copy the API endpoint from the output above"
    echo "2. Update web/src/config.js with your API endpoint"
    echo "3. Set CLOUD_SYNC: true in web/src/config.js"
    echo "4. Rebuild and redeploy your frontend"
else
    echo "❌ Deployment failed"
    exit 1
fi
