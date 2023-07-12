![AppCommander Icon](https://github.com/BomberFish/AppCommander/assets/87151697/e6705d37-150d-4f0f-982c-a5a39f8f0b09)
# AppCommander

A swiss army knife for your iPhone apps using [CVE-2022-46689](https://support.apple.com/en-us/HT213530).

IPA available in the [Releases](https://github.com/BomberFish/AppCommander/releases/latest) section.

## Supported versions

- iOS 15.0-15.4.1: **Not officially supported.**
- iOS 15.5-15.7.1: **Supported.**
- iOS **15**.7.2+: **Not supported.**
- iOS 16.0-16.1.2: **Supported.**
- iOS 16.2+: **Not supported.**

## Features
- **App Manager**
  - List all installed apps, including hidden system apps.
  - Backup and restore app data (importing .abdk backups is also supported)
  - View app details
  - Delete app data/cache
  - View and modify app documents
  - Enable JIT*
  - Export encrypted IPAs
- **Sort Home Screen by app names or icon colors**
- **Miscellaneous Tools**
  - Whitelist (remove enterprise certificate blacklist)
  - Remove three-app-limit
  - Manually refresh icon cache

*JIT can only be enabled if AppCommander is signed using a (free) developer certificate and after following the setup process in `Settings > Set up JIT`.

## Installing
You can install through AltStore, Sideloadly, or Xcode. 

TrollStore is not officially supported, and using enterprise signing apps such as Scarlet or ESign will not allow you to import backups.

## Suggestions and support
You can create an issue on this repo, or join the [Cowabunga Discord server](https://discord.gg/Cowabunga) where I or someone else can help you in the #appcommander channel.

## Analytics
AppCommander uses [TelemetryDeck](https://telemetrydeck.com) to collect anonymized analytics data. You can disable any data collection in the Settings tab, and view TelemetryKit's [privacy policy](https://telemetrydeck.com/privacy/).

## Building
Just build like a normal Xcode project. Sign using your own team and bundle identifier. You can also build the IPA file by running `make`.

## Credits
Credits can be viewed in the app by going to `Settings > About AppCommander`.
