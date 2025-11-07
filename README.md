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

