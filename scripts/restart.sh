#!/bin/bash

APP_DIR="/home/ubuntu/myapp"
LOG_FILE="$APP_DIR/deploy.log"

echo "----------------------------------" >> "$LOG_FILE"
echo "Deployment started at $(date)" >> "$LOG_FILE"

cd "$APP_DIR" || {
  echo "Failed to cd into $APP_DIR" >> "$LOG_FILE"
  exit 1
}

# Install dependencies
echo "Installing npm packages..." >> "$LOG_FILE"
npm install >> "$LOG_FILE" 2>&1

# Start Redis if not running
if pgrep redis-server > /dev/null; then
  echo "Redis is already running." >> "$LOG_FILE"
else
  echo "Starting Redis server..." >> "$LOG_FILE"
  sudo systemctl start redis >> "$LOG_FILE" 2>&1
fi

# Ensure FFmpeg is available
if ! command -v ffmpeg &> /dev/null; then
  echo "FFmpeg not found. Installing..." >> "$LOG_FILE"
  sudo apt-get update >> "$LOG_FILE" 2>&1
  sudo apt-get install -y ffmpeg >> "$LOG_FILE" 2>&1
else
  echo "FFmpeg is already installed." >> "$LOG_FILE"
fi

# PM2 setup
echo "Managing Node.js app with PM2..." >> "$LOG_FILE"
if ! command -v pm2 &> /dev/null; then
  echo "PM2 not found. Installing..." >> "$LOG_FILE"
  sudo npm install -g pm2 >> "$LOG_FILE" 2>&1
fi

# Restart the app
if pm2 describe myapp > /dev/null; then
  pm2 restart myapp >> "$LOG_FILE" 2>&1
else
  pm2 start index.js --name myapp >> "$LOG_FILE" 2>&1
fi

# Ensure PM2 restarts on reboot
pm2 save >> "$LOG_FILE" 2>&1
pm2 startup systemd -u ubuntu --hp /home/ubuntu >> "$LOG_FILE" 2>&1

echo "Deployment completed at $(date)" >> "$LOG_FILE"

