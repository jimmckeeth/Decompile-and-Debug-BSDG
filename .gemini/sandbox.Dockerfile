# Use the latest Ubuntu (Same base as Mint 22)
FROM ubuntu:24.04

# Prevents Ubuntu from asking you "What is your Timezone?" during install
ENV DEBIAN_FRONTEND=noninteractive

# Install the tools you are used to
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    curl \
    wget \
    iputils-ping \
    nano \
    # 'software-properties-common' lets you use 'add-apt-repository' command
    software-properties-common \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /workspace

# Keep the container running
CMD ["tail", "-f", "/dev/null"]