#!/bin/bash
# This script will revert the changes made by the Docker setup script.

# Colors for text formatting
RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color

display_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# User input for the container port
#read -p "Enter the Container Port (eg :): " container_port

# User input for the system port
read -p "Enter the System Port (eg: 8086): " system_port

# User input for the Image Name
read -p "Enter an image name (including version, e.g., saru23/mnsp_frontend:1.0): " image_name


# Get the container ID based on the image name
#image_name="YourImageName"  # Replace with the actual image name or ID
container_id=$(sudo docker ps -q --filter ancestor="$image_name")

if [ -z "$container_id" ]; then
    echo -e "${YELLOW}No running container found for image: $image_name${NC}"
else
    # Remove the Docker container
    echo -e "${YELLOW}...Removing Docker container...${NC}"
    if sudo docker stop "$container_id" && sudo docker rm "$container_id"; then
        echo -e "${GREEN}Docker container successfully removed.${NC}"
    else
        display_error "Failed to remove Docker container."
    fi
fi

# Remove the Docker image
echo -e "${YELLOW}...Removing Docker image...${NC}"
if sudo docker rmi "$image_name"; then
    echo -e "${GREEN}Docker image successfully removed.${NC}"
else
    display_error "Failed to remove Docker image."
fi


#Removing the docker completely
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get purge docker docker-engine docker.io containerd runc
sudo apt-get autoremove

if sudo docker rmi $(sudo docker images -aq) 


# Remove the Dockerfile
#dockerfile_path="Dockerfile"
echo -e "${YELLOW}...Removing Dockerfile...${NC}"
if sudo rm Dockerfile; then
    echo -e "${GREEN}Dockerfile successfully removed.${NC}"
else
    display_error "Failed to remove Dockerfile."
fi
