#!/bin/bash

# Flutter Deploy Script
# Universal deployment script for web, Android, and iOS

set -e  # Exit on error

# Colors for terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
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

# Get current version from pubspec.yaml
get_current_version() {
    grep "version:" pubspec.yaml | head -1 | sed 's/version: //'
}

# Menu selection
show_menu() {
    echo -e "\n${BLUE}Select platform for deployment:${NC}"
    echo "1) Web"
    echo "2) Android"
    echo "3) iOS"
    echo "4) All (Web, Android, iOS)"
    echo "5) Clean & Pub Get only (no build)"
    echo "0) Exit"
    echo ""
}

# Project preparation
prepare_project() {
    print_header "CLEANUP AND PREPARATION"
    
    print_info "Removing build cache..."
    flutter clean
    
    print_info "Fetching dependencies..."
    flutter pub get
    
    print_success "Project prepared"
}

# Version update
update_version() {
    local current_version=$(get_current_version)
    print_info "Current version: $current_version"
    
    echo -e "\n${BLUE}How do you want to update the version?${NC}"
    echo "1) Increase build number (default)"
    echo "2) Enter new version manually"
    echo ""
    read -p "Choice [1-2]: " version_choice
    
    if [ "$version_choice" = "2" ]; then
        read -p "Enter new version (e.g. 1.1.0+2): " new_version
        sed -i '' "s/version: .*/version: $new_version/" pubspec.yaml
        print_success "Version changed to: $new_version"
    else
        # Increase build number
        local version_part=$(echo $current_version | cut -d'+' -f1)
        local build_number=$(echo $current_version | cut -d'+' -f2)
        local new_build=$((build_number + 1))
        local new_version="$version_part+$new_build"
        sed -i '' "s/version: .*/version: $new_version/" pubspec.yaml
        print_success "Version changed to: $new_version"
    fi
}

# Build Web
build_web() {
    print_header "BUILDING WEB"
    
    print_info "Building web application (release)..."
    flutter build web --release
    
    print_success "Web build completed!"
    print_info "Files located in: build/web/"
    
    # Firebase deploy prompt
    echo ""
    read -p "Do you want to deploy to Firebase Hosting now? (y/n): " firebase_choice
    if [ "$firebase_choice" = "y" ] || [ "$firebase_choice" = "Y" ]; then
        deploy_firebase
    fi
}

# Build Android
build_android() {
    print_header "BUILDING ANDROID"
    
    echo -e "\n${BLUE}Select format:${NC}"
    echo "1) APK (for testing)"
    echo "2) App Bundle (for Google Play Store)"
    echo ""
    read -p "Choice [1-2]: " android_choice
    
    if [ "$android_choice" = "2" ]; then
        print_info "Building App Bundle..."
        flutter build appbundle --release
        print_success "App Bundle completed!"
        print_info "File located in: build/app/outputs/bundle/release/app-release.aab"
    else
        print_info "Building APK..."
        flutter build apk --release
        print_success "APK build completed!"
        print_info "File located in: build/app/outputs/apk/release/app-release.apk"
    fi
}

# Build iOS
build_ios() {
    print_header "BUILDING iOS"
    
    print_info "Building iOS application (release)..."
    flutter build ios --release
    
    print_success "iOS build completed!"
    print_info "Next steps:"
    echo "  1. Open Xcode: open ios/Runner.xcworkspace"
    echo "  2. Select 'Product' → 'Archive'"
    echo "  3. Use Archive Manager to submit to App Store"
}

# Firebase Deploy
deploy_firebase() {
    print_header "FIREBASE DEPLOYMENT"
    
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed!"
        echo "Install it with: npm install -g firebase-tools"
        return 1
    fi
    
    print_info "Logging in to Firebase..."
    firebase login --no-localhost 2>/dev/null || true
    
    print_info "Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    
    print_success "Firebase deployment completed!"
}

# Main flow
main() {
    print_header "FLUTTER DEPLOYMENT SCRIPT"
    print_info "Project: flutter_application_1"
    
    # Update version
    update_version
    
    # Prepare project
    prepare_project
    
    # Menu selection
    while true; do
        show_menu
        read -p "Choice [0-5]: " choice
        
        case $choice in
            1)
                build_web
                ;;
            2)
                build_android
                ;;
            3)
                build_ios
                ;;
            4)
                build_web
                build_android
                build_ios
                ;;
            5)
                print_success "Project is clean and ready to use!"
                ;;
            0)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Try again."
                ;;
        esac
        
        # Continue prompt
        echo ""
        read -p "Do you want to build something else? (y/n): " continue_choice
        if [ "$continue_choice" != "y" ] && [ "$continue_choice" != "Y" ]; then
            print_header "DEPLOYMENT COMPLETED"
            print_success "All operations completed successfully!"
            exit 0
        fi
    done
}

# Error handling
trap 'print_error "Error during deployment! Check previous messages."; exit 1' ERR

# Check if we are in the project root directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Error: pubspec.yaml not found!"
    print_info "Run the script from the project root directory"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH!"
    exit 1
fi

# Run main flow
main
