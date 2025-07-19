#!/bin/bash

# Atharva AI Extension Troubleshooting Script
# This script helps diagnose and fix common issues with the Xcode extension

echo "🔍 Atharva AI Extension Troubleshooting Guide"
echo "=============================================="
echo ""

# Check if the app is properly built
APP_PATH="/Users/ayanchakraborty/Library/Developer/Xcode/DerivedData/Atharva_AI-efyzkecdiwsltjczxexjcsvkzmlx/Build/Products/Debug/Atharva AI.app"
EXTENSION_PATH="$APP_PATH/Contents/PlugIns/Atharva Extension.appex"

echo "1. Checking App Build Status..."
if [ -d "$APP_PATH" ]; then
    echo "✅ App found at: $APP_PATH"
else
    echo "❌ App not found. Please build the project first."
    exit 1
fi

echo ""
echo "2. Checking Extension Bundle..."
if [ -d "$EXTENSION_PATH" ]; then
    echo "✅ Extension found at: $EXTENSION_PATH"
else
    echo "❌ Extension not found in app bundle."
    exit 1
fi

echo ""
echo "3. Checking Extension Info.plist..."
EXTENSION_INFO="$EXTENSION_PATH/Contents/Info.plist"
if [ -f "$EXTENSION_INFO" ]; then
    echo "✅ Extension Info.plist found"
    
    # Check bundle identifier
    BUNDLE_ID=$(defaults read "$EXTENSION_INFO" CFBundleIdentifier 2>/dev/null)
    echo "   Bundle ID: $BUNDLE_ID"
    
    # Check extension commands
    COMMANDS=$(defaults read "$EXTENSION_INFO" NSExtension 2>/dev/null | grep -A 5 "XCSourceEditorCommandDefinitions")
    if [[ $COMMANDS == *"AI Code Completion"* ]]; then
        echo "✅ Extension commands properly configured"
    else
        echo "❌ Extension commands not found"
    fi
else
    echo "❌ Extension Info.plist not found"
fi

echo ""
echo "4. Registering Extension with System..."
# Re-register the app with Launch Services
/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -f -R "$APP_PATH"
echo "✅ App re-registered with Launch Services"

echo ""
echo "5. Checking System Extensions..."
# List Xcode extensions
echo "Current Xcode Extensions:"
/usr/bin/pluginkit -m -p com.apple.dt.Xcode.extension.source-editor -A 2>/dev/null | grep -E "(identifier|displayName)" || echo "No extensions found"

echo ""
echo "6. Extension Enablement Instructions:"
echo "   1. Open System Preferences"
echo "   2. Go to Extensions → Xcode Source Editor"
echo "   3. Enable 'Atharva AI' if it appears"
echo ""
echo "   OR"
echo ""
echo "   1. Open Xcode Preferences (⌘,)"
echo "   2. Go to Extensions tab"
echo "   3. Enable 'Atharva AI' under Source Editor"
echo ""

echo "7. If Extension Still Not Visible:"
echo "   • Restart Xcode completely"
echo "   • Run this script again"
echo "   • Check that the main app is running"
echo "   • Try building and running from Xcode directly"

echo ""
echo "8. Testing the Extension:"
echo "   1. Open any Swift file in Xcode"
echo "   2. Go to Editor → Atharva AI"
echo "   3. You should see 'AI Code Completion' and 'AI Refactor Code'"

echo ""
echo "✅ Troubleshooting complete!"
