# Uruk Motors — Deployment Guide for Spaceship Supreme

## Prerequisites
- Spaceship Supreme hosting with Node.js enabled
- MySQL database created via cPanel
- Domain: uruk-services.com

## Step 1: Create MySQL Database via cPanel

1. Login to cPanel → **MySQL Databases**
2. Create database: `uruk_motors`
3. Create user: `uruk_admin` with a strong password
4. Add user to database with **ALL PRIVILEGES**
5. Note down: host (usually `localhost`), username, password, database name

## Step 2: Setup Node.js App via cPanel

1. Go to cPanel → **Setup Node.js App** (or Development tools → Node.js)
2. Click **Create Application**
3. Settings:
   - Node.js version: 18+ (latest available)
   - Application mode: Production
   - Application root: `/backend` (or wherever you upload the files)
   - Application URL: `uruk-services.com`
   - Application startup file: `server.js`
4. Click **Create**
5. Note the command shown to enter the virtual environment

## Step 3: Upload Files

1. Upload the entire `backend/` folder contents to the application root
2. Upload the `website/` folder to the same level as backend

## Step 4: Configure Environment

1. In the Node.js app settings, or via SSH, create `.env` file:
```
PORT=3000
NODE_ENV=production
BASE_URL=https://uruk-services.com

DB_HOST=localhost
DB_PORT=3306
DB_USER=uruk_admin
DB_PASSWORD=YOUR_DB_PASSWORD
DB_NAME=uruk_motors

JWT_SECRET=CHANGE_THIS_TO_RANDOM_64_CHARS
ADMIN_JWT_SECRET=CHANGE_THIS_TO_DIFFERENT_RANDOM_64_CHARS
JWT_EXPIRES_IN=30d
ADMIN_JWT_EXPIRES_IN=8h

UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
```

2. For Twilio (when ready), add:
```
TWILIO_ACCOUNT_SID=ACxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxx
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxx
```

## Step 5: Install Dependencies & Initialize DB

Via SSH or cPanel terminal:
```bash
cd ~/backend
npm install
node config/init-db.js
```

## Step 6: Start/Restart the App

In cPanel → Node.js app → Click **Restart**

## Step 7: Verify

- API health: `https://uruk-services.com/health`
- Dashboard: `https://uruk-services.com/dashboard`
- Login with: admin@uruk.iq / 123456

## Flutter App Configuration

In `lib/services/api_service.dart`, update:
```dart
static const String _baseUrl = 'https://uruk-services.com/api';
```

## File Structure on Server
```
~/
├── backend/
│   ├── server.js          (entry point)
│   ├── package.json
│   ├── .env               (secrets - DO NOT commit)
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── routes/
│   ├── utils/
│   └── uploads/           (user-uploaded files)
└── website/
    ├── index.html
    ├── js/
    └── css/
```
