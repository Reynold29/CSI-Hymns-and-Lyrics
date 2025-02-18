#!/bin/bash

# This is a script used to generate an IPA file of the Flutter App.
## !!! NOTE !!! THIS IS MEANT ONLY FOR TESTING ON YOUR PERSONAL DEVICE USING YOUR PERSONAL SIGNING KEYS AND APPLE ID. This doesn't demonstrate how to sideload the IPA file.
# To find out how to publish / release an iOS App in Flutter, please refer official documentation: https://docs.flutter.dev/deployment/ios

# This creates an unsigned build of an IPA file which can be sideloaded to your PERSONAL iPhone for TESTING PURPOSES ONLY!

# Clean the existing iOS build folder
flutter clean -d ios

# Get Dependencies
flutter pub get

# Build iOS IPA
flutter build ios --release --no-codesign

# Prepare IPA file
cd build/ios/iphoneos
mkdir Payload
mv Runner.app/ Payload
zip -qq -r -9 HymnsApp.ipa Payload # Change your App Name accordingly

# Open Finder Window with the built IPA
open .
