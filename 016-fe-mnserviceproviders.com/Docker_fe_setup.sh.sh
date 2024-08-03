#!/bin/bash
# This script will set up a Docker container for a front-end application using Nginx.

# Colors for text formatting
RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color
BLUE='\033[34m'    # Blue Color

display_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
    display_error "This script must be run as root."
fi

# Update system
echo -e "${YELLOW}...Updating the system...${NC}"
if ! sudo apt update; then 
    display_error "System failed to update."
fi

# Check if Docker is installed
echo -e "${YELLOW}...Docker installation and setup...${NC}"
if [ -x "$(command -v docker)" ]; then
    echo "${GREEN}Docker is already installed.${NC}"
else
    # Install Docker
    echo -e "${YELLOW}Installing Docker...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker.io
    if ! [ -x "$(command -v docker)" ]; then
        display_error "Docker installation failed."
    else
        echo "${GREEN}Docker is successfully installed.${NC}"
    fi
fi

# Check if Docker is running
echo -e "${YELLOW}...Checking if Docker is running...${NC}"
if sudo systemctl is-active --quiet docker; then
    echo "${GREEN}Docker is running.${NC}"
else
    # Start Docker
    echo "${YELLOW}Starting Docker...${NC}"
    sudo systemctl start docker
    sudo systemctl enable docker
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Docker successfully started.${NC}"
    else
        display_error "Docker failed to start."
    fi
fi

# Make sure that the project files are available in the home directory
echo -e "${YELLOW}...Make sure that the project files are available in the home directory...${NC}"


# User input for the system port
read -p "Enter the System Port (eg : 8086): " system_port

# User input for the Image Name
read -p "Enter an image name (including version, e.g., saru23/mnsp_frontend:1.0): " image_name


# Writing the Dockerfile
dockerfile_path="Dockerfile"
echo -e "${YELLOW}...Writing the Dockerfile...${NC}"
cat <<EOL > "$dockerfile_path"
FROM nginx:1.21

# Set the working directory to the web root
WORKDIR /usr/share/nginx/html

# Copy the content of your front-end application into the container
COPY mnsp_Website/ .

# Expose the default Nginx port
EXPOSE 80

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]
EOL

# Check if Dockerfile is created successfully
if [ ! -f "$dockerfile_path" ]; then
    display_error "Failed to create Dockerfile."
fi

# Build the image with Dockerfile 
echo -e "${YELLOW}...Building the image with Dockerfile...${NC}"
if ! sudo docker build -t "$image_name" .; then
    display_error "Docker image build failed."
fi

# Running the container
echo -e "${YELLOW}...Running The Container...${NC}"
if ! sudo docker run -d -p "$system_port:80" "$image_name"; then
    display_error "Failed to run the Docker container."
fi
