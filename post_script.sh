#!/bin/bash

# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install Node.js 20.16.0 & npm 9.2.0
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # Verify Node.js version
npm -v   # Verify npm version

# Install FFmpeg
sudo apt install -y ffmpeg

# Install PM2 globally
sudo npm install -g pm2

# Create the application directory
sudo mkdir -p /home/ubuntu/nodejs
cd /home/ubuntu/nodejs

# Ensure correct ownership (prevents permission issues)
sudo chown -R ubuntu:ubuntu /home/ubuntu/nodejs

# Install Nginx
sudo apt install -y nginx

# Create Nginx configuration for reverse proxy
cat <<EOL | sudo tee /etc/nginx/sites-available/backend
server {
    listen 80;
    server_name your-backend-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Enable the Nginx configuration
sudo ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/

# Restart and enable Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
