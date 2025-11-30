# Deployment Guide

## Prerequisites

- Node.js 18+ installed
- AWS CLI configured (`aws configure`)
- AWS SAM CLI installed (for backend)
- GitHub account (for CI/CD)

## Frontend Deployment

### Option A: AWS Amplify (Recommended)

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/smart-check.git
   git push -u origin main
   ```

2. **Connect to Amplify**
   - Go to [AWS Amplify Console](https://console.aws.amazon.com/amplify)
   - Click "New app" → "Host web app"
   - Connect your GitHub repository
   - Amplify auto-detects build settings:
     ```yaml
     version: 1
     frontend:
       phases:
         preBuild:
           commands:
             - cd web
             - npm install
         build:
           commands:
             - npm run build
       artifacts:
         baseDirectory: web/dist
         files:
           - '**/*'
       cache:
         paths:
           - web/node_modules/**/*
     ```
   - Click "Save and deploy"

3. **Custom Domain (Optional)**
   - In Amplify Console, go to "Domain management"
   - Add your custom domain
   - Follow DNS configuration steps

### Option B: S3 + CloudFront

1. **Build the app**
   ```bash
   cd web
   npm install
   npm run build
   ```

2. **Create S3 bucket**
   ```bash
   aws s3 mb s3://smart-check-frontend
   ```

3. **Configure bucket for static hosting**
   ```bash
   aws s3 website s3://smart-check-frontend \
     --index-document index.html \
     --error-document index.html
   ```

4. **Upload files**
   ```bash
   aws s3 sync dist/ s3://smart-check-frontend --acl public-read
   ```

5. **Create CloudFront distribution**
   - Go to CloudFront Console
   - Create distribution
   - Origin: Your S3 bucket
   - Enable HTTPS
   - Set default root object: `index.html`
   - Create custom error response: 404 → /index.html (for SPA routing)

## Backend Deployment

1. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Build with SAM**
   ```bash
   sam build
   ```

3. **Deploy**
   ```bash
   sam deploy --guided
   ```

   Answer prompts:
   - Stack name: `smart-check-backend`
   - AWS Region: `us-east-1` (or your preferred region)
   - Confirm changes: `Y`
   - Allow SAM CLI IAM role creation: `Y`
   - Save arguments to config: `Y`

4. **Get API endpoint**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name smart-check-backend \
     --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
     --output text
   ```

5. **Update frontend config**
   Create `web/src/config.js`:
   ```javascript
   export const API_ENDPOINT = 'https://your-api-id.execute-api.us-east-1.amazonaws.com/prod'
   ```

## CI/CD Setup

### GitHub Actions (for S3 deployment)

1. **Add secrets to GitHub**
   - Go to repo Settings → Secrets and variables → Actions
   - Add:
     - `AWS_S3_BUCKET`: your-bucket-name
     - `AWS_REGION`: us-east-1
     - `AWS_ACCESS_KEY_ID`: your-access-key
     - `AWS_SECRET_ACCESS_KEY`: your-secret-key

2. **Push to trigger deployment**
   ```bash
   git push origin main
   ```

### Amplify CI/CD

Amplify automatically deploys on every push to `main`. No additional setup needed!

## Monitoring

### CloudWatch Logs
```bash
# View Lambda logs
aws logs tail /aws/lambda/smart-check-backend-AddItemFunction --follow

# View API Gateway logs
aws logs tail /aws/apigateway/smart-check-api --follow
```

### Set up alarms
```bash
# Create alarm for Lambda errors
aws cloudwatch put-metric-alarm \
  --alarm-name smart-check-lambda-errors \
  --alarm-description "Alert on Lambda errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold
```

## Troubleshooting

### CORS Issues
If you see CORS errors, ensure:
- Lambda functions return proper CORS headers
- API Gateway has CORS enabled
- CloudFront/Amplify forwards headers correctly

### Build Failures
```bash
# Clear cache and rebuild
cd web
rm -rf node_modules dist
npm install
npm run build
```

### DynamoDB Access Issues
Check Lambda IAM role has DynamoDB permissions:
```bash
aws iam get-role-policy \
  --role-name smart-check-backend-AddItemFunctionRole \
  --policy-name DynamoDBCrudPolicy
```

## Cleanup

To delete all resources:

```bash
# Delete backend stack
sam delete --stack-name smart-check-backend

# Delete S3 bucket
aws s3 rb s3://smart-check-frontend --force

# Delete CloudFront distribution (via console)
```

For Amplify, delete the app from the Amplify Console.
