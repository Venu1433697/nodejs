#!/bin/bash

APP_DIR="/home/ubuntu/main-backend"
LOG_FILE="$APP_DIR/deploy.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")


mkdir -p "$APP_DIR"
echo "----------------------------------" >> "$LOG_FILE"
echo "Deployment started at $TIMESTAMP" >> "$LOG_FILE"



# Install project dependencies
echo "Installing npm packages..." >> "$LOG_FILE"
npm install >> "$LOG_FILE" 2>&1

# Start Redis server if not already running
if pgrep redis-server > /dev/null; then
  echo "Redis is already running." >> "$LOG_FILE"
else
  echo "Starting Redis server..." >> "$LOG_FILE"
  sudo systemctl start redis >> "$LOG_FILE" 2>&1
fi

# Ensure FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
  echo "FFmpeg not found. Installing..." >> "$LOG_FILE"
  sudo apt-get update >> "$LOG_FILE" 2>&1
  sudo apt-get install -y ffmpeg >> "$LOG_FILE" 2>&1
else
  echo "FFmpeg is already installed." >> "$LOG_FILE"
fi

# Manage the app using PM2
echo "Setting up PM2..." >> "$LOG_FILE"
if ! command -v pm2 &> /dev/null; then
  echo "Installing PM2 globally..." >> "$LOG_FILE"
  sudo npm install -g pm2 >> "$LOG_FILE" 2>&1
fi

# Restart or start the app with PM2
if pm2 describe main-backend > /dev/null; then
  echo "Restarting existing PM2 process 'main-backend'" >> "$LOG_FILE"
  pm2 restart main-backend >> "$LOG_FILE" 2>&1
else
  echo "Starting new PM2 process 'main-backend'" >> "$LOG_FILE"
  pm2 start src/index.js --name main-backend >> "$LOG_FILE" 2>&1
fi

# Ensure PM2 auto-starts on reboot
pm2 save >> "$LOG_FILE" 2>&1
pm2 startup systemd -u ubuntu --hp /home/ubuntu >> "$LOG_FILE" 2>&1


echo "Deployment completed at $(date)" >> "$LOG_FILE"
