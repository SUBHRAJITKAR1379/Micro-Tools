# Smart-Check — A Minimal Smart Kitchen Expiry Tracker (Built with Kiro & AWS)

## Introduction

Food waste is a massive problem. According to the UN, roughly one-third of all food produced globally goes to waste. For families and students managing busy schedules, tracking expiration dates manually is tedious and error-prone. You buy milk, forget about it, and discover it expired three days ago.

**Smart-Check** solves this with a simple, privacy-first web app that:
- Tracks kitchen items with expiration dates
- Scans QR codes for instant item entry
- Shows visual status indicators (Safe 🟢 / Expiring Soon 🟡 / Expired 🔴)
- Works offline-first with optional cloud sync

This post walks through how I built Smart-Check end-to-end on AWS, and how **Kiro** (an AI-powered IDE assistant) accelerated development by generating boilerplate, fixing bugs, and suggesting best practices.

---

## What I Built

Smart-Check is a responsive single-page application with these core features:

### Core Features
- **Add Items Manually**: Form with name, expiry date, quantity, and category
- **QR Code Scanning**: Client-side scanning using html5-qrcode (privacy-first — no camera data leaves your device)
- **Visual Status System**: 
  - 🟢 Safe (>5 days until expiry)
  - 🟡 Expiring Soon (1-5 days)
  - 🔴 Expired (past expiry date)
- **Offline-First**: Uses localStorage for instant access
- **Cloud Sync** (optional): DynamoDB backend for multi-device access
- **Clean UI**: Tailwind CSS with a modern color palette

### Tech Stack

**Frontend:**
- React 18 + Vite (fast dev experience)
- Tailwind CSS (utility-first styling)
- html5-qrcode (client-side QR scanning)

**Backend (Optional):**
- AWS Lambda (serverless compute)
- API Gateway (REST API)
- DynamoDB (NoSQL database, pay-per-request)
- AWS SAM (Infrastructure as Code)

**Hosting & CI/CD:**
- AWS Amplify or S3 + CloudFront
- GitHub Actions for automated deployment

---

## Design & User Experience

### Color Palette
I chose a clean, modern palette that's easy on the eyes:
- **Primary**: `#6C63FF` (vibrant purple for CTAs)
- **Background**: `#F7F8FC` (soft gray-blue)
- **Status Colors**:
  - Safe: `#4CAF50` (green)
  - Warning: `#FFC107` (amber)
  - Danger: `#F44336` (red)

### Layout
The app uses a card-based layout with:
- **Header**: App title and description
- **Add Item Card**: Form for manual entry
- **Item Grid**: Responsive grid (1 col mobile, 3 cols desktop)
- **Status Bar**: Colored top border on each card indicating status

Each item card shows:
- Item name (bold)
- Expiry date, quantity, category
- Status label with days remaining
- Delete button

---

## Architecture

### Client-Only Mode (Simplest)
```
User Browser
    ↓
React App (Vite)
    ↓
localStorage (offline persistence)
```

### Full Stack Mode (Multi-Device Sync)
```
User Browser → CloudFront/Amplify
    ↓
React App
    ↓
API Gateway → Lambda Functions
    ↓
DynamoDB (SmartCheckItems table)
```

**Why Serverless?**
- Zero server management
- Pay only for what you use
- Auto-scaling built-in
- Perfect for small-to-medium traffic apps

---

## How Kiro Helped Build This

Kiro was instrumental in accelerating development. Here's how:

### 1. Date Diff Logic (5 minutes saved)
I asked Kiro: *"Generate a function to calculate days until expiry and return status"*

Kiro instantly produced:

```javascript
const status = useMemo(() => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const expiry = new Date(item.expiryDate)
  expiry.setHours(0, 0, 0, 0)
  const daysLeft = Math.ceil((expiry - today) / (1000 * 60 * 60 * 24))

  if (daysLeft < 0) {
    return { label: 'Expired', color: 'bg-danger', days: daysLeft }
  } else if (daysLeft <= 5) {
    return { label: 'Expiring Soon', color: 'bg-warning', days: daysLeft }
  } else {
    return { label: 'Safe', color: 'bg-safe', days: daysLeft }
  }
}, [item.expiryDate])
```

Perfect! It handled edge cases (midnight normalization) and used `useMemo` for performance.

### 2. QR Scanner Modal (15 minutes saved)
I asked: *"Create a React modal component using html5-qrcode for QR scanning"*

Kiro generated the full component with proper cleanup:
```javascript
useEffect(() => {
  const scanner = new Html5QrcodeScanner(
    'qr-reader',
    { fps: 10, qrbox: { width: 250, height: 250 } },
    false
  )
  scanner.render(
    (decodedText) => {
      onScan(decodedText)
      scanner.clear()
    },
    (error) => { /* ignore scanning errors */ }
  )
  return () => scanner.clear().catch(console.error)
}, [onScan])
```

### 3. Lambda Functions (20 minutes saved)
Kiro scaffolded all three Lambda handlers (add, get, delete) with:
- Proper error handling
- CORS headers
- DynamoDB SDK calls
- Environment variable usage

### 4. SAM Template (10 minutes saved)
I asked: *"Generate AWS SAM template for API Gateway + Lambda + DynamoDB"*

Kiro produced a complete CloudFormation template with:
- DynamoDB table with proper keys
- API Gateway with CORS
- Lambda functions with IAM policies
- Outputs for API endpoint

**Total time saved: ~2 hours** of boilerplate writing, debugging, and documentation lookup.

---

## Implementation Highlights

### Key Code Snippet: Add Item Logic

```javascript
const addItem = (item) => {
  const newItem = {
    ...item,
    id: Date.now().toString(),
    createdAt: new Date().toISOString()
  }
  setItems([...items, newItem])
}

// Persist to localStorage
useEffect(() => {
  localStorage.setItem('smartcheck_items', JSON.stringify(items))
}, [items])
```

Simple, effective, and works offline immediately.

### QR Code Format
For QR codes, I defined a simple JSON format:
```json
{
  "name": "Amul Milk",
  "expiryDate": "2025-12-10",
  "qty": "1",
  "category": "dairy"
}
```

Users can generate these QR codes using any online QR generator and print labels for their kitchen items.

---

## Deployment to AWS

### Option 1: AWS Amplify (Fastest)
```bash
# Push to GitHub
git push origin main

# In AWS Console:
# 1. Go to Amplify Console
# 2. Connect GitHub repo
# 3. Amplify auto-detects React + Vite
# 4. Deploy!
```

Amplify provides:
- Automatic HTTPS
- CI/CD on every push
- Preview deployments for PRs
- Custom domain support

### Option 2: S3 + CloudFront (Manual)
```bash
cd web
npm run build

# Create S3 bucket
aws s3 mb s3://smart-check-frontend

# Upload files
aws s3 sync dist/ s3://smart-check-frontend --acl public-read

# Enable static website hosting
aws s3 website s3://smart-check-frontend \
  --index-document index.html \
  --error-document index.html
```

Then create a CloudFront distribution pointing to the S3 bucket for CDN and HTTPS.

### Backend Deployment (SAM)
```bash
cd backend
npm install
sam build
sam deploy --guided
```

SAM will:
- Package Lambda functions
- Create DynamoDB table
- Set up API Gateway
- Output the API endpoint URL

Update `web/src/config.js` with your API endpoint.

---

## CI/CD with GitHub Actions

The included workflow (`.github/workflows/deploy.yml`) automatically:
1. Installs dependencies
2. Builds the React app
3. Syncs to S3 on every push to `main`

Just add these secrets to your GitHub repo:
- `AWS_S3_BUCKET`
- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

## Security & Privacy

### Privacy-First QR Scanning
- All QR scanning happens **client-side** using html5-qrcode
- Camera frames never leave the user's device
- No third-party services involved

### API Security (if using backend)
- Use AWS Cognito for authentication
- Add Cognito authorizer to API Gateway
- Validate user tokens in Lambda
- Use HTTPS everywhere (CloudFront/Amplify provides this)

### Input Sanitization
- Validate all form inputs
- Escape user-generated content to prevent XSS
- Use parameterized DynamoDB queries

---

## Cost Estimate

For a personal/small team use case:

**Frontend (S3 + CloudFront):**
- S3 storage: ~$0.023/GB/month
- CloudFront: First 1TB free tier, then $0.085/GB
- **Estimated**: $1-5/month

**Backend (Lambda + DynamoDB + API Gateway):**
- Lambda: 1M requests free/month
- DynamoDB: 25GB storage + 200M requests free
- API Gateway: 1M requests free/month
- **Estimated**: Free tier covers most personal use

**Total**: $0-10/month depending on traffic

---

## Future Improvements

### Phase 2 (Short-term)
- User authentication (Cognito)
- Search and filters (by category, expiring soon)
- Export/Import JSON
- Bulk add via CSV upload

### Phase 3 (Advanced)
- **Smart Suggestions**: Integrate OpenFoodFacts API to auto-fill product details from barcode
- **Notifications**: Daily email reminders via SES for items expiring today
- **Analytics Dashboard**: Track monthly waste saved, most wasted categories
- **Mobile Apps**: React Native wrapper for iOS/Android with push notifications
- **Printable QR Labels**: Generate and print QR code sheets for common items

---

## Challenges & Solutions

### Camera Permissions
Getting browser camera access to work reliably was tricky. Different browsers handle permissions differently, and macOS has system-level camera permissions that can conflict. 

**Solution:** Enhanced error handling, clear user feedback, and comprehensive troubleshooting documentation. Also provided manual entry as a fallback.

### Date Calculations
Calculating "days until expiry" accurately required normalizing dates to midnight to avoid off-by-one errors caused by time zones.

**Solution:** Used `setHours(0, 0, 0, 0)` on both dates and `useMemo` for performance.

### QR Code Validation
Users might scan any QR code, not just Smart-Check formatted ones.

**Solution:** Wrapped JSON parsing in try-catch, validated required fields, provided defaults for optional fields, and showed helpful error messages.

### State Management
Balancing offline-first (localStorage) with future cloud sync required careful planning.

**Solution:** Started simple with localStorage, designed data structure to support future backend integration without breaking changes.

### Responsive Design
QR scanner modal and item cards needed to work well on both mobile and desktop.

**Solution:** Tailwind's responsive utilities (`md:`, `lg:`) and mobile-first design approach. Tested on real devices.

For detailed technical challenges and solutions, see [CHALLENGES.md](./CHALLENGES.md).

## Lessons Learned

1. **Start Simple**: The localStorage-only version took 2 hours and works great offline
2. **Serverless Scales**: Adding DynamoDB sync was straightforward with SAM
3. **Kiro Accelerates**: AI assistance saved hours on boilerplate and debugging
4. **Privacy Matters**: Client-side QR scanning builds user trust
5. **AWS Free Tier**: Perfect for MVPs and personal projects
6. **Test on Real Devices**: Camera features behave differently on actual phones vs browser DevTools
7. **Plan for Editing**: CRUD operations should be considered from the start

---

## Try It Yourself

**Live Demo**: [https://smart-check.example.com](#)  
**GitHub Repo**: [https://github.com/yourusername/smart-check](#)

### Quick Start
```bash
git clone https://github.com/yourusername/smart-check.git
cd smart-check/web
npm install
npm run dev
```

---

## Conclusion

Smart-Check demonstrates how modern web technologies and AWS serverless services can solve real-world problems with minimal infrastructure overhead. The combination of React, Tailwind, and AWS Lambda creates a fast, scalable, and cost-effective solution.

Using Kiro during development cut implementation time significantly, allowing me to focus on features rather than boilerplate. If you're building on AWS, I highly recommend trying Kiro for your next project.

**What would you track with Smart-Check?** Let me know in the comments!

---

*Built during Kiro Week 1 Challenge*  
*Tags: #AWS #Serverless #React #Kiro #FoodWaste #SmartKitchen*
