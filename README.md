# BottleScout

BottleScout is an iOS app for scanning wine/beer/spirits bottles, enriching details with Gemini, and tracking what you currently own.

## Current v1 Feature Set

- Camera-first home screen (launches to capture flow)
- Bottom controls:
  - Left: choose existing photo
  - Center: open camera
  - Right: inventory
- AI bottle analysis with structured fields:
  - Name
  - Type
  - Price range
  - Tasting notes
  - Pairing notes
- Bottle detail screen with:
  - Large bottle image
  - Top-right owned/not-owned toggle
  - Type, price, tasting notes, pairing notes, scan date
- Inventory list:
  - Sorted by scan date (newest first)
  - Filter: All / Owned / Not Owned
- Local persistence via SwiftData

## Requirements

- Xcode 15+
- iOS 17+
- Gemini API key

## Setup

1. Copy the local config template:

```bash
cp Config.local.xcconfig.template Config.local.xcconfig
```

2. Open `Config.local.xcconfig` and set:

```xcconfig
GEMINI_API_KEY = your-real-key
```

3. Open `BottleScout.xcodeproj` and run the `BottleScout` scheme.

## Project Notes

- API key is loaded from `Info.plist` build setting `GEMINI_API_KEY` (via xcconfig), not hardcoded in Swift.
- Gemini prompt requests structured JSON and best-effort market/tasting/pairing data.
- If the model response is malformed, the parser falls back to safe default strings so users can still save bottles.

## Testing

- App target: `BottleScout`
- Unit test target: `BottleScoutTests`

Run in Xcode or with `xcodebuild`.
