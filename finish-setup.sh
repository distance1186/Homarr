#!/bin/bash
# Homarr Docker Setup Script

echo "=== Completing Docker Setup ==="

# Add user to docker group
echo "Adding user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose plugin
echo "Installing Docker Compose plugin..."
sudo apt-get install -y docker-compose-plugin

# Enable Docker service
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

# Verify installation
echo ""
echo "Verifying installation..."
docker --version
docker compose version

echo ""
echo "=== Setup Complete! ==="
echo "You need to log out and back in for group changes to take effect."
echo ""
echo "After logging back in:"
echo "  cd ~/Homarr"
echo "  docker compose up -d"