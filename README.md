# NQueensTests

## Build & Run

Open `NQueens.xcodeproj` in Xcode 26+ and run the **NQueensTests** target (`Cmd+U`).

No third-party dependencies or extra setup required — the project uses only SwiftUI and CoreData.

## Architecture Decisions

### MVVM + Protocol-Based DI

The app follows MVVM with constructor-injected dependencies behind protocols:

```
View  ->  ViewModel  ->  BestTimesServiceProtocol  ->  BestTimesStoreProtocol
                              |                              |
                        BestTimesService              BestTimesStore (CoreData)
```

Each layer depends only on the protocol above it, so tests substitute real implementations with mocks (`MockBestTimesService`, `MockBestTimesStore`) — no CoreData container needed for ViewModel tests.

### `@MainActor` без async/await

`NQueensViewModel` явно помечен `@MainActor`, чтобы гарантировать обновление UI-состояния на главном потоке. При этом проект не использует асинхронный код (`async/await`) — все операции (расстановка ферзей, проверка конфликтов, сохранение рекордов) достаточно лёгкие и выполняются синхронно. `@MainActor` здесь нужен не для переключения потоков, а для соответствия требованиям `@Observable` и SwiftUI.

На уровне проекта установлен `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, поэтому все типы неявно изолированы. Тестовые классы аннотированы `@MainActor` явно, чтобы вызовы через границу изоляции компилировались без ошибок.

## Test Structure

```
NQueensTests/
  Mocks/
    Mocks.swift                    # MockBestTimesService, MockBestTimesStore
  Tests/
    NQueensViewModelTests.swift    # Game logic, conflicts, win condition
    BestTimesServiceTests.swift    # Record save/fetch/comparison
    CellDataTests.swift            # Board cell model
    GameRecordTests.swift          # Time formatting
```


### In-Memory CoreData for Service Tests

`BestTimesServiceTests` creates a throwaway `NSPersistentContainer` with `NSInMemoryStoreType` to build real `Record` objects without touching disk.
