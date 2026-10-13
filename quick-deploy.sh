#!/bin/bash

# Flutter Quick Deploy Script
# Fast automated web deployment - no questions, everything automatic

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if we are in the project root directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found! Run the script from the project root directory."
    exit 1
fi

print_header "QUICK DEPLOY - WEB ONLY"

# Update version (increase build number)
print_info "Updating version..."
current_version=$(grep "version:" pubspec.yaml | head -1 | sed 's/version: //')
version_part=$(echo $current_version | cut -d'+' -f1)
build_number=$(echo $current_version | cut -d'+' -f2)
new_build=$((build_number + 1))
new_version="$version_part+$new_build"

sed -i '' "s/version: .*/version: $new_version/" pubspec.yaml
# Update APP_VERSION in auth_provider.dart
sed -i '' "s/const String APP_VERSION = .*/const String APP_VERSION = '$new_version';/" lib/providers/auth_provider.dart
print_success "Version updated: $current_version → $new_version"

# Clean & Pub Get
print_header "CLEANUP"
print_info "Removing cache..."
flutter clean
print_info "Fetching dependencies..."
flutter pub get

# Web Build
print_header "BUILDING WEB"
print_info "Building application (release)..."
flutter build web --release
print_success "Web build completed!"

# Firebase Deploy
if command -v firebase &> /dev/null; then
    print_header "FIREBASE DEPLOYMENT"
    read -p "Do you want to deploy to Firebase now? (y/n): " deploy_choice
    if [ "$deploy_choice" = "y" ] || [ "$deploy_choice" = "Y" ]; then
        print_info "Deploying..."
        firebase deploy --only hosting
        print_success "Firebase deployment completed!"
    fi
else
    print_info "Firebase CLI not installed. Skipping Firebase deployment."
fi

print_header "DEPLOY COMPLETED"
print_success "All done! Files in: build/web/"

