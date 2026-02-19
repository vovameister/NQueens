# NQueens

An iOS puzzle game where you place N non-attacking queens on an N×N chessboard.

## Build & Run

Open `NQueens.xcodeproj` in Xcode 16+ and run the **NQueens** target on a simulator or device (`Cmd+R`).
To run tests: select the **NQueensTests** target and press `Cmd+U`.

No third-party dependencies or extra setup required

---

## Architecture

### Overview

The app follows **MVVM** with protocol-based dependency injection throughout. All dependencies are constructor-injected, which makes the code testable without any mocking frameworks.

```
┌─────────────────────────────────────────────────────┐
│                     NQueensView                      │
│  (SwiftUI, renders state, forwards user actions)     │
└───────────────────────┬─────────────────────────────┘
                        │ @Observable
                        ▼
┌─────────────────────────────────────────────────────┐
│                 NQueensViewModel                     │
│  @MainActor — owns all game state:                  │
│  • queens: Set<Position>                            │
│  • conflicts: Set<Position>                         │
│  • cellsData: [CellData]                            │
│  • state: GameState                                 │
│  • timer, elapsedTime                               │
└────────────┬──────────────────────┬─────────────────┘
             │                      │
             ▼                      ▼
┌────────────────────┐   ┌──────────────────────────┐
│ BestTimesService   │   │       SoundPlayer         │
│ (BestTimesService- │   │  (SoundPlaying protocol)  │
│  Protocol)         │   │  @MainActor class plays   │
│                    │   │  move and victory sounds   │
│                    │   │  via AVAudioPlayer         │
│  • addResult       │   │  • preloads assets once   │
│  • getResults      │   │    on init                │
│  • getBestTime     │   │  • playMove()             │
│  • isNewRecord     │   │  • playVictory()          │
└────────┬───────────┘   └──────────────────────────┘
         │
         ▼
┌────────────────────┐
│  BestTimesStore    │
│ (BestTimesStore-   │
│  Protocol)         │
│  CoreData backend: │
│  • saveRecord      │
│  • fetchRecords    │
│  • deleteOldRecords│
└────────────────────┘
```

### Key Design Decisions

**`@Observable` + `@MainActor`**
`NQueensViewModel` is annotated with both `@Observable` (Swift 5.9 observation) and `@MainActor`, so all state mutations happen on the main thread and views update automatically without manual `objectWillChange` calls.

**Single game state**
The view model exposes one `GameState` enum for the main flow (`settingUp`, `playing`, `editingSettings`, `won`, and completed-game review) instead of keeping separate stored booleans for timer, alerts, interaction, and record UI.

**Protocol-based DI**
Every dependency (`BestTimesServiceProtocol`, `BestTimesStoreProtocol`, `SoundPlaying`) is injected through a protocol. This makes it trivial to swap in mocks in tests without any third-party frameworks.

**Main-actor audio**
`SoundPlayer` is a regular `@MainActor` class. The view model is also main-actor isolated, so audio calls stay on the UI side without extra actor hops, and both sound assets are preloaded during initialization.

**`RecordDTO` as a Sendable boundary**
CoreData `NSManagedObject` instances are not `Sendable` and cannot cross actor boundaries. `BestTimesStore` maps them to `RecordDTO` (a plain `Sendable` struct) before returning, keeping CoreData objects safely inside their background context.

**Conflict detection algorithm**
`updateConflicts()` runs an O(N²) pairwise check over placed queens. For board sizes 4–12 (maximum 144 queens worst case) this is negligible. Queens are stored in a `Set<Position>` for O(1) lookup during cell rebuild.

---

## Test Structure

```
NQueensTests/
  Mocks/
    Mocks.swift                    # MockBestTimesService, MockBestTimesStore, MockSoundPlayer
  Tests/
    NQueensViewModelTests.swift    # Game logic, conflict detection, win condition, timer
    BestTimesServiceTests.swift    # Record save / fetch / ranking logic
    CellDataTests.swift            # Board cell model, checkerboard pattern
    GameRecordTests.swift          # Time formatting
```

### Mocking Strategy

Mocks use simple class-backed state objects to capture side effects from async calls:

```swift
final class MockBestTimesServiceState: @unchecked Sendable { var addedResults: [...] = [] }
final class MockBestTimesService: BestTimesServiceProtocol, Sendable {
    let state = MockBestTimesServiceState()
}
```

This keeps the test doubles lightweight while still letting tests assert on what was called.
