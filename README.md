# flutter_application_1
# Sandwich Shop

A small Flutter sample app that models a sandwich ordering counter. The app demonstrates a simple separation of concerns: UI lives in `lib/main.dart` while the order quantity logic is centralized in `lib/repositories/order_repository.dart`.

This repository includes unit tests for business logic and a small widget test to exercise the UI.

## Features

- Increment and decrement sandwich order quantity with min/max bounds
- Choose bread type and sandwich size (six-inch / footlong)
- Add an order note
- Centralized order logic in `OrderRepository` with `quantity`, `canIncrement`, and `canDecrement`
- Unit tests for repository logic and a basic widget test

## Project layout (important files)

- `lib/main.dart` — The main app entry and UI. Contains `App`, `OrderScreen`, `OrderItemDisplay`, and `StyledButton`.
- `lib/repositories/order_repository.dart` — Single source of truth for the order quantity and logic (increment/decrement + bounds).
- `lib/views/app_styles.dart` — Shared `TextStyle` constants.
- `test/repositories/order_repository_test.dart` — Unit tests for `OrderRepository`.
- `test/views/widget_test.dart` — A basic widget test that verifies the UI increments the counter.

## Quick start

Prerequisites

- Flutter SDK installed and on your PATH.

Get dependencies

```bash
flutter pub get
```

Run the app (device or simulator)

```bash
flutter run
```

Run tests

```bash
flutter test
```

## Why `OrderRepository` exists

We moved quantity-related state and logic into `OrderRepository` so UI code focuses on rendering and interaction. The repository:

- Holds the `_quantity` field as the single source of truth
- Exposes `quantity` getter for reads
- Exposes `canIncrement` / `canDecrement` boolean getters to encapsulate bounds checks
- Exposes `increment()` / `decrement()` methods to mutate state safely

This keeps business rules centralized and easy to test.

## Notes about the widget test and the UI change

The widget test in `test/views/widget_test.dart` looks for a plain numeric `Text` node with `'0'` and `'1'`. To keep the test simple and stable the UI contains a dedicated `Text(quantity.toString())` inside `OrderItemDisplay`, so `find.text('0')` and `find.text('1')` succeed. If you prefer not to expose a separate numeric `Text`, update the test to search for the composed sentence or use a `WidgetPredicate`.

## Common issues & quick fixes

- LateInitializationError for `_orderRepository`:
	- Fix: initialize the repository in `initState()` (recommended). Alternatively, make the field nullable and guard reads, but initializing in `initState` is simpler and prevents runtime access before initialization.

- Tests failing to find `'0'`:
	- Fix A (current): add a dedicated numeric `Text` widget in the UI (done in this branch).
	- Fix B: update the widget test to locate and parse the composed display string.

## Development tips

- Keep business rules in `OrderRepository`. Changing min/max bounds or rules should only require repository updates and tests.
- Use `canIncrement` / `canDecrement` from the repository to decide whether increment/decrement controls are enabled.
- Mutate repository state using `repository.increment()` / `repository.decrement()` inside `setState(...)` so UI updates correctly.

## Suggested commit messages

Short (one-line):

```
feat(order): introduce OrderRepository, refactor OrderScreenState, add tests
```

Conventional commit (recommended):

```
feat(order): introduce OrderRepository and refactor OrderScreenState; add unit and widget tests
```

Detailed (PR description):

```
feat(order): introduce OrderRepository; refactor UI to use repository; add/fix tests

- Add lib/repositories/order_repository.dart with quantity, canIncrement, canDecrement, increment(), decrement()
- Initialize repository in initState and read repository.quantity from UI
- Add a dedicated numeric Text in OrderItemDisplay so widget test can find '0'/'1'
- Add unit tests for OrderRepository
```

## Contributing

Contributions and improvements are welcome. If you change public behavior, add tests and update this README accordingly.

## License

This project is an example. Add a LICENSE file if you plan to publish or distribute this project.
