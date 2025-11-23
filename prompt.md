Title: Implement cart modification UX and logic (change quantity, remove items, edit item options) for Sandwich Shop Flutter app

Context
- Repo models:
  - `Sandwich` — fields: `type` (SandwichType), `isFootlong` (bool), `breadType` (BreadType). `image` and `name` getters exist.
  - `Cart` — holds CartItem(s) (Sandwich + quantity) and exposes: addSandwich(...), removeAt(index) / removeItemByKey(...), updateQuantity(index, qty) or similar, `totalQuantity`, `totalPrice`.
- Repository:
  - `PricingRepository` — single source of truth for pricing. Price depends only on `isFootlong` (footlong vs six-inch) and quantity. Use its `calculatePrice({required int quantity, required bool isFootlong})`.
- Goal: Allow users to modify items already added to cart from the cart screen (no separate backend syncing, but design for easy extension). Keep changes local (in-memory) and update UI and price immediately. Write widget/unit tests.

Requirements to implement (for each feature include UI, state change, and tests)
1) Change item quantity (increment/decrement + direct input)
- UI:
  - On the cart screen, each cart row shows sandwich name, size text (six-inch/footlong), bread type, current quantity, item subtotal.
  - Provide:
    - "+" button (increase)
    - "−" button (decrease)
    - Optional numeric TextField or Stepper to edit quantity exactly
  - Provide semantic/test keys for automation:
    - Row key: `Key('cart_item_row_<index>')`
    - Increment button: `Key('cart_item_<index>_increment')`
    - Decrement button: `Key('cart_item_<index>_decrement')`
    - Quantity field: `Key('cart_item_<index>_quantity')`
    - Subtotal text: `Key('cart_item_<index>_subtotal')`
- Behavior:
  - Increment: quantity++, update item subtotal and cart totals immediately.
  - Decrement: quantity-- (not below 0). If quantity reaches 0, remove the item from cart OR prompt user depending on option chosen (see Removal below). Default: when quantity is decremented to 0, item is removed.
  - Direct input: if user types a number ≤ 0, treat as remove. If not a number, ignore or show validation error.
  - Enforce any `maxQuantity` if app requires (pass via parameter or use a sensible upper bound like 99).
- Tests:
  - Unit test for Cart.updateQuantity/increment/decrement (happy path + edge cases).
  - Widget test: tapping increment increases quantity and updates subtotal and cart summary (keys above).
  - Widget test: tapping decrement eventually removes row when quantity reaches 0.

2) Remove item entirely
- UI:
  - Add a remove action on each row (trash icon or “Remove” button).
  - Key: `Key('cart_item_<index>_remove')`
  - Optionally show an Undo SnackBar after removal with action 'Undo'.
- Behavior:
  - On remove, delete the item from Cart, update totals.
  - Show a SnackBar ("Removed X from cart") with an Undo action. If Undo pressed within SnackBar duration, restore the item with previous quantity.
- Tests:
  - Widget test: press remove, row disappears, totals update.
  - Widget test: press remove, then Undo, row returns and totals restored.

3) Edit sandwich options in cart (size and bread)
- UI:
  - Allow a small "Edit" action on each row that opens a modal bottom sheet or inline editors to change `isFootlong` and `breadType`.
  - Keys:
    - `Key('cart_item_<index>_edit')`
    - inside modal: `Key('edit_size_switch')`, `Key('edit_bread_dropdown')`, `Key('edit_save_button')`
- Behavior:
  - When user changes size (footlong <-> six-inch), item's `isFootlong` toggles and item subtotal and cart totals update (use PricingRepository).
  - If the change would merge this item with an existing identical sandwich in the cart (same type, size, bread, note), then merge quantities and remove duplicate row (or prompt). Preferred: merge automatically and show a small info SnackBar "Merged with existing item".
- Tests:
  - Widget test: edit size -> subtotal updates and total updates.
  - Widget test: editing to match another row merges them and updates totals.

4) Cart summary permanence & updates
- UI:
  - Keep the cart summary visible on the cart screen (items count and total price). Keys:
    - `Key('cart_summary_item_count')`
    - `Key('cart_summary_total_price')`
- Behavior:
  - All modifications should update cart summary immediately and deterministically.
- Tests:
  - Widget tests to confirm cart summary updates after add/remove/quantity edit.

5) UX details and edge cases
- Validation and bounds:
  - Reject negative quantities.
  - Apply `maxQuantity` if passed; show message if user attempts to exceed.
- Undo & optimistic updates:
  - UI should reflect changes instantly (optimistic). For a future server sync, provide ways to rollback (Undo).
- Accessibility:
  - Buttons must have semantic labels for screen readers.
- Performance:
  - Keep per-row updates local (use setState on row-level widgets or a state management solution).
- Consistency:
  - Use `PricingRepository.calculatePrice(...)` to compute per-item subtotal and cart total (do not duplicate logic).

6) State interactions & integration points
- Use existing `Cart` model methods for changes: addSandwich, removeAt / removeItemByKey, updateQuantity.
- If `Cart` lacks an operation you need (e.g., updateSandwichOptions), implement it in `lib/models/cart.dart`:
  - `updateItem(index, {int? quantity, Sandwich? sandwich})` -> updates fields, returns merged flag or removed flag.
  - Keep private helper(s) that generate deterministic keys for merging.
- Keep the model pure (no UI code in model).

7) Files to edit (suggested)
- lib/screens/cart_screen.dart (create or update): implement the cart UI list, row widget, edit modal.
- lib/widgets/cart_item_row.dart (optional): a reusable widget for each cart row.
- lib/models/cart.dart: add updateItem/merge logic if missing.
- test/widgets/cart_screen_test.dart: widget tests for UI flows.
- test/models/cart_test.dart or update existing to cover the Cart model changes.

8) Keys & selectors for tests (repeat)
- Cart row: `Key('cart_item_row_<index>')`
- Increment: `Key('cart_item_<index>_increment')`
- Decrement: `Key('cart_item_<index>_decrement')`
- Quantity field: `Key('cart_item_<index>_quantity')`
- Subtotal: `Key('cart_item_<index>_subtotal')`
- Remove: `Key('cart_item_<index>_remove')`
- Edit: `Key('cart_item_<index>_edit')`
- Cart summary keys: `Key('cart_summary_item_count')`, `Key('cart_summary_total_price')`
- SnackBar Undo action: label 'Undo'

9) Acceptance criteria (deliverables)
- Users can increment/decrement/set quantity from cart screen and subtotals & totals update immediately.
- Users can remove items and undo the removal using a SnackBar.
- Users can edit size/bread for cart items; prices update and identical items merge.
- Unit tests for model operations (happy path + edge cases).
- Widget tests that exercise add, increment, decrement, remove+undo, edit and merging behavior.
- All tests pass.

10) Extra: Example behavior snippets (to include in implementation)
- Increment button pressed:
  - UI: quantity increments, per-item subtotal updates (use PricingRepository), cart summary updates, no navigation.
- Remove pressed:
  - UI: item row removed, cart summary updates, SnackBar appears with 'Undo'; undo restores row.
- Edit size to match another row:
  - UI: item merges into target row; final quantity is sum, row count decreases by 1, SnackBar 'Merged with existing item'.

Instruction to the LLM you call
- Implement the UI and model changes in the repo layout above. Keep things small and test-driven: add/modify unit tests for `Cart` and widget tests for the cart screen. Use provided keys to make tests reliable. Use the `PricingRepository.calculatePrice` for all pricing logic, do not invent new pricing formulas. Provide a short README note inside `lib/screens/cart_screen.dart` explaining used keys and test hooks.

Tone for the generated code
- Idiomatic Dart/Flutter (null-safety)
- Minimal changes to the rest of the app
- Add inline comments for public methods and tests
- Use keys exactly as specified for test stability

If you need the exact file paths in this repository or want me to implement these changes now, say so and I will apply them and run the tests.