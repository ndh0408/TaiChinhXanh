#!/bin/bash

echo "🚀 Starting APK build process..."
echo "================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"

# Clean previous builds
echo -e "\n${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "\n${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Build APK
echo -e "\n${YELLOW}🔨 Building APK...${NC}"
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ APK build successful!${NC}"
    
    # Find and display APK location
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$APK_PATH" ]; then
        echo -e "\n${GREEN}📱 APK location:${NC}"
        echo "   $(pwd)/$APK_PATH"
        
        # Get APK size
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        echo -e "\n${GREEN}📊 APK size: $APK_SIZE${NC}"
    fi
else
    echo -e "\n${RED}❌ APK build failed!${NC}"
    echo "Please check the error messages above."
    exit 1
fi

echo -e "\n================================"
echo "Build completed!"