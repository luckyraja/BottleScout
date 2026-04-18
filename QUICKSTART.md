# BottleScout Quick Start

## 1. Configure API Key

```bash
cp Config.local.xcconfig.template Config.local.xcconfig
```

Edit `Config.local.xcconfig`:

```xcconfig
GEMINI_API_KEY = your-real-gemini-api-key
```

## 2. Build and Run

1. Open `BottleScout.xcodeproj`
2. Select scheme `BottleScout`
3. Run on a simulator/device

## 3. Main Flow

1. App opens to camera-first home screen
2. Capture a bottle or choose an existing photo
3. Review AI output (name/type/price/tasting/pairing)
4. Save to inventory
5. Use inventory filter for Owned / Not Owned

## 4. Verify Core Behavior

- Launch opens camera-first shell
- Bottom-left opens photo library flow
- Bottom-right opens inventory
- Capturing/selecting image pushes bottle review screen
- Saved bottle appears in inventory with newest-first ordering
- Bottle detail top-right icon toggles owned state

## 5. Tests

- Unit tests live in `BottleScoutTests` target
