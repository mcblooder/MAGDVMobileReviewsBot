# Dockerfile

### BUILD STAGE ###

# Use Swift official image as the base image for building
FROM swift:latest AS builder

# Install packages needed for building
RUN apt-get update && apt-get install -y libsqlite3-dev


# Set the working directory inside the builder container
WORKDIR /app

# Copy the Swift project files to the builder container
COPY . .

# Resolve SPM dependencies
RUN swift package resolve

# Build the Swift project statically with release configuration
RUN swift build -v --static-swift-stdlib -c release

### RUN STAGE ###

# Using Debian as the runtime base image to ensure compatibility with glibc
# TODO: Migrate to Alpine after Swift 6 release for a smaller image size
FROM debian:latest

# Install necessary packages for cron and runtime dependencies
RUN apt-get update && apt-get install -y \
    cron \
    curl \
    ca-certificates \
    libsqlite3-0 \
    libcurl4 \
    libgcc1 \
    libstdc++6 \
    libssl3 \
    zlib1g

# Copy executable from builder
COPY --from=builder /app/.build/release/MAGDVMobileReviewsBot /app/MAGDVMobileReviewsBot

# Create a cron job script to run every hour
RUN echo "0 * * * * cd /app && /app/MAGDVMobileReviewsBot > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/swift-cron

# Give execution rights to the cron job file
RUN chmod 0644 /etc/cron.d/swift-cron

# Add crontab
RUN crontab /etc/cron.d/swift-cron

# Run the command on container startup
CMD [ "cron", "-f"]
