# Smart-Check 🥛

A minimal smart kitchen expiry tracker that helps you reduce food waste by tracking expiration dates with QR code scanning.

![Smart-Check Demo](./assets/screenshots/demo.gif)

## Features

- 📱 Client-side QR code scanning (privacy-first, no data leaves your device)
- 🎨 Visual status indicators (Safe 🟢 / Expiring Soon 🟡 / Expired 🔴)
- ✏️ Edit items after adding them
- 🏷️ Auto-categorization from QR codes (beverages, dairy, fruits, etc.)
- 💾 Offline-first with localStorage
- ☁️ Optional cloud sync across devices (DynamoDB)
- 🔐 User authentication (AWS Cognito)
- 📊 Clean, responsive UI with status-based color coding

## Tech Stack

**Frontend:** React + Vite + Tailwind CSS  
**QR Scanning:** html5-qrcode  
**Backend:** AWS Lambda + API Gateway + DynamoDB  
**Auth:** AWS Cognito  
**Hosting:** AWS Amplify / S3 + CloudFront  
**CI/CD:** GitHub Actions

## Quick Start (Local Development)

```bash
# Clone the repo
git clone https://github.com/yourusername/smart-check.git
cd smart-check

# Install and run frontend
cd web
npm install
npm run dev
```

Visit `http://localhost:5173`

## QR Code Format

Smart-Check automatically reads category and other details from QR codes. Use this JSON format:

```json
{
  "name": "Coca Cola",
  "expiryDate": "2025-12-31",
  "qty": "2",
  "category": "beverages"
}
```

**Supported categories:** `beverages`, `dairy`, `vegetables`, `fruits`, `meat`, `other`

Generate QR codes using `tools/generate-qr.html` - just open it in your browser!

## Deployment

### Option A: AWS Amplify (Recommended)

1. Push code to GitHub
2. Go to [AWS Amplify Console](https://console.aws.amazon.com/amplify)
3. Connect your repository
4. Amplify auto-detects build settings
5. Deploy!

### Option B: S3 + CloudFront

```bash
cd web
npm run build
aws s3 sync dist/ s3://smart-check-frontend --acl public-read
```

See [deployment guide](./docs/DEPLOYMENT.md) for CloudFront setup.

## Backend Setup (Optional - for multi-device sync)

```bash
cd backend
npm install
sam build
sam deploy --guided
```

Update `web/src/config.js` with your API Gateway endpoint.

## How Kiro Helped

During development, Kiro accelerated the build by:
- Auto-generating the date diff logic for expiry status calculation
- Producing the QR scanner modal component with html5-qrcode integration
- Creating the DynamoDB Lambda handlers in under 10 minutes
- Fixing CORS issues and suggesting proper error handling

See the full story in our [AWS Builder Center blog post](#).

## Project Structure

```
smart-check/
├─ web/                    # React frontend
├─ backend/                # Lambda functions + SAM template
├─ assets/                 # Icons, screenshots
├─ .kiro/                  # Kiro metrics
└─ README.md
```

## License

MIT

## Live Demo

🔗 [https://smart-check.example.com](#)
