# Base image
FROM ubuntu:latest AS build

# Set working directory
WORKDIR /app

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Run basic check to download Dart/Flutter dependencies
RUN flutter doctor -v

# Copy files to container and build
COPY . .
RUN flutter clean
RUN flutter pub get
RUN flutter build web --release

# Stage 2 - Create the run-time image
FROM nginx:stable-alpine

# Copy build output from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]