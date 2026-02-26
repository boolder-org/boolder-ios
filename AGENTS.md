# Boolder iOS

## Cursor Cloud specific instructions

### Platform constraint

This is a **native iOS app** (Swift/SwiftUI) that requires **macOS + Xcode** to build and run. The Cloud Agent Linux VM cannot compile, build, or run the iOS simulator. The following sections describe what *is* possible on Linux.

### What works on Linux

- **Linting**: `swiftlint lint` runs against all 85 `.swift` files (uses the static binary at `~/bin/swiftlint`). The project has no `.swiftlint.yml` config, so default rules apply. Exit code 2 is expected (existing violations in the repo).
- **SQLite database inspection**: The bundled read-only database at `Boolder/Stores/boolder.db` can be queried with `sqlite3` for data validation (19K+ problems, 90 areas, 271 circuits, etc.).
- **Code review and static analysis**: All Swift source is under `Boolder/` with models in `Boolder/Models/`, UI in `Boolder/UI/`, and data stores in `Boolder/Stores/`.

### What requires macOS

- Building the app: `xcodebuild -scheme "Boolder dev" -destination "platform=iOS Simulator,name=iPhone 16"` (or via Xcode GUI)
- Running tests: The Xcode schemes have empty `<Testables>` sections — no automated test targets exist in the project currently.
- Resolving SPM dependencies: Mapbox Maps iOS SDK, SQLite.swift, and Turf Swift are managed via Xcode's integrated Swift Package Manager. A secret Mapbox token with `DOWNLOADS:READ` scope must be in `~/.netrc` for SPM to fetch the Mapbox SDK (see `README.md` for details).

### Key external dependency

The app requires a **Mapbox account** with two tokens:
1. Public token stored in `~/.mapbox`
2. Secret token (with `DOWNLOADS:READ` scope) stored in `~/.netrc`

See `README.md` > "Mapbox setup" for full instructions.
