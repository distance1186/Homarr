#!/bin/bash
# Homarr Docker Setup Script for Ubuntu VM

set -e

echo "=== Homarr Docker Setup ==="
echo ""

# Update system
echo "1. Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Docker
echo ""
echo "2. Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Add user to docker group
echo ""
echo "3. Adding user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose plugin
echo ""
echo "4. Installing Docker Compose plugin..."
sudo apt-get install -y docker-compose-plugin

# Enable Docker service
echo ""
echo "5. Enabling Docker to start on boot..."
sudo systemctl enable docker

# Verify installation
echo ""
echo "6. Verifying installation..."
docker --version
docker compose version

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "IMPORTANT: You need to log out and log back in for group changes to take effect."
echo "After logging back in, you can run Docker commands without sudo."
echo ""
echo "Next steps:"
echo "1. Log out: exit"
echo "2. SSH back in from Windows: ssh $(whoami)@172.16.10.216"
echo "3. Navigate to Homarr directory and start the container"
