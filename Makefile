all: clean build entitlements package clean

PROJECT = $(shell basename *.xcodeproj)
WORKING_LOCATION := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TARGET = AppCommander
CONFIGURATION = Release
SDK = iphoneos
KEYFILE := ./APIKeys.swift
KEYVAR := ${TELEMETRYDECK_APPID}


build:

	@if [ ! -f $(KEYFILE) ]; then \
			echo "import Foundation\nlet telemetryDeckID = \"$(KEYVAR)\"" > $(KEYFILE); \
      echo "App ID written to file."; \
  else \
      echo "App ID file already exists."; \
  fi

	echo "Building $(TARGET) for $(SDK)..."
	xcodebuild -project $(PROJECT) -scheme $(TARGET) -configuration $(CONFIGURATION) -sdk $(SDK) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO SYMROOT=$(PWD)/build clean
	xcodebuild -project $(PROJECT) -scheme $(TARGET) -configuration $(CONFIGURATION) -sdk $(SDK) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO SYMROOT=$(PWD)/build -resolvePackageDependencies
	xcodebuild -project $(PROJECT) -scheme $(TARGET) -configuration $(CONFIGURATION) -sdk $(SDK) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO SYMROOT=$(PWD)/build build
	echo "Build finished!"

entitlements:
	echo "Adding entitlements..."
	chmod a+x $(WORKING_LOCATION)bin/ldid
	$(WORKING_LOCATION)bin/ldid -S"$(WORKING_LOCATION)entitlements.plist" "build/$(CONFIGURATION)-$(SDK)/$(TARGET).app"
	echo "Entitlements added!"

package:
	echo "Packaging app..."
	rm -rf Payload
	mkdir Payload
	cp -r build/$(CONFIGURATION)-$(SDK)/$(TARGET).app Payload
	zip -r $(TARGET).ipa Payload
	echo "Packaging finished!"

clean:
	rm -rf Payload
	rm -rf build
	echo "All done!"
