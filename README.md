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
│  • timer, elapsedTime                               │
└────────────┬──────────────────────┬─────────────────┘
             │                      │
             ▼                      ▼
┌────────────────────┐   ┌──────────────────────────┐
│ BestTimesService   │   │       SoundPlayer         │
│ (BestTimesService- │   │  (SoundPlaying protocol)  │
│  Protocol)         │   │  actor — plays move and   │
│                    │   │  victory sounds via        │
│  • addResult       │   │  AVAudioPlayer            │
│  • getResults      │   │  • preloads assets once   │
│  • getBestTime     │   │    on init                │
│  • isNewRecord     │   │  • playMove()             │
└────────┬───────────┘   │  • playVictory()          │
         │               └──────────────────────────┘
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

**Protocol-based DI**
Every dependency (`BestTimesServiceProtocol`, `BestTimesStoreProtocol`, `SoundPlaying`) is injected through a protocol. This makes it trivial to swap in mocks in tests without any third-party frameworks.

**`actor` for SoundPlayer**
`SoundPlayer` is an `actor` because `AVAudioPlayer` is not thread-safe. All audio operations are serialized automatically, and `init` kicks off a `Task` to preload both sound assets so the first move has no latency.

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

Mocks use an **actor-isolated state object** pattern to safely capture side-effects from async calls:

```swift
actor MockBestTimesServiceState { var addedResults: [...] = [] }
final class MockBestTimesService: BestTimesServiceProtocol, Sendable {
    let state = MockBestTimesServiceState()
}
```

This avoids data races in async tests while still letting tests assert on what was called.

### In-Memory CoreData for Service Tests

`BestTimesServiceTests` injects `MockBestTimesStore` instead of the real CoreData store, so no disk I/O happens during tests and each test starts with a clean slate.
