## Cart Modification Feature — Requirements

### Overview
This document specifies the Cart Modification feature: allow users to change cart item quantities, remove items with Undo, and edit item options (size and bread). It includes user stories, acceptance criteria, API contracts, test keys, subtasks and edge cases so developers and QA can implement and verify the behavior consistently.

### Purpose
- Improve user control over orders by enabling editing of cart items after add.
- Provide a clear, accessible and testable UI for incrementing/decrementing quantities, removing items with Undo and editing item options.
- Maintain accurate pricing using the existing `PricingRepository`.
- Prevent accidental duplicates by merging identical items when appropriate.

### Scope
Included:
- Cart row controls for increment / decrement and direct quantity edits.
- Remove item action with Undo via SnackBar.
- Edit item modal dialog to change size/bread.
- Merge logic when edited item matches an existing item.
- Unit tests for the Cart model and widget tests for UI flows.
- Stable widget keys for deterministic automated tests.

Excluded:
- Inventory/stock reservation.
- Remote sync with a backend (unless already present elsewhere in the app).
- Promotions and coupons.

### Stakeholders
- End users (shoppers)
- QA engineers
- Developers
- Product owner

### Assumptions
- `PricingRepository` remains the authoritative source for price calculation.
- `Sandwich` model has deterministic equality for matching (or a helper function will be used to evaluate equality for merge).
- Image assets use a consistent naming convention (for example: `veggieDelight_six_inch.png`).
- Cart is an in-memory model updated synchronously.

### Constraints
- Keep UI changes localized to limit regression risk.
- Use the existing state-management approach (simple `Cart` model + setState) unless otherwise agreed.

## Feature Description (Detailed)

1. Cart UI changes
   - Add a `cart_screen` listing `CartItem` rows. Each row includes:
     - Sandwich thumbnail and name.
     - Size and bread description.
     - Quantity display and controls:
       - Increment button (`cart_item_<id>_increment`).
       - Decrement button (`cart_item_<id>_decrement`). If quantity reaches 0, remove item with Undo.
       - (Optional) direct numeric input for accessibility.
     - Edit button (`cart_item_<id>_edit`) to change size/bread.
     - Remove button (`cart_item_<id>_remove`).
     - Row-level key: `cart_item_row_<id>` where `id` is a stable `cartItem.id`.

2. Edit Item Modal
   - Modal contains:
     - Sandwich image and name.
     - Size selection (six-inch vs footlong).
     - Bread selection.
     - Save (`edit_item_save_<id>`) and Cancel (`edit_item_cancel_<id>`) actions.
   - Save behavior:
     - If no effective change, close modal.
     - If edited configuration matches another cart item, merge quantities and remove the edited row; show SnackBar describing merge with Undo.
     - Otherwise, update the item in place.

3. Remove / Undo
   - Removal triggers a SnackBar (`cart_undo_snack`) with Undo action.
   - Undo restores the removed item and prior totals.
   - Undo window configurable (4–6 seconds recommended).

4. Merge logic
   - Items match if they have the same sandwich type, same size, and same bread.
   - On merge, quantities are summed and the edited row removed.

5. Cart model API
   - Methods to provide and their expected behaviors:
     - `addItem(Sandwich s, int qty) -> cartItemId`
     - `incrementQuantity(String id)`
     - `decrementQuantity(String id)` (removes when qty <= 0)
     - `updateQuantity(String id, int newQty)`
     - `editItem(String id, Sandwich newConfig) -> {mergedIntoId: String?|null, updatedId: String?|null}`
     - `removeItem(String id) -> CartItem` (returns removed item for Undo)
     - `restoreItem(CartItem item)` (restores previously removed item)
     - `totalPrice` and `totalQuantity` derived from current cart using `PricingRepository`.

6. Test keys (stable selectors for automation)
   - `cart_screen`
   - `cart_item_row_<id>`
   - `cart_item_<id>_increment`
   - `cart_item_<id>_decrement`
   - `cart_item_<id>_quantity`
   - `cart_item_<id>_edit`
   - `cart_item_<id>_remove`
   - `edit_item_modal_<id>`
   - `edit_item_save_<id>` / `edit_item_cancel_<id>`
   - `cart_undo_snack`
   - `cart_item_count` and `cart_total_price` (existing summary keys)

7. Accessibility
   - All buttons must have semantic labels describing the action and item.
   - Modal and list should be keyboard-navigable and focusable.

8. Error handling & UX
   - Prevent negative quantities; clamp direct input to >= 0.
   - On local failures, show an error SnackBar with key `cart_action_error` and preserve prior state where possible.

## Data & API Contracts

CartItem shape
- `id: String` (stable)
- `sandwich: Sandwich` (type & options)
- `quantity: int` (>=1)
- `unitPrice: double` (derived)
- `subtotal: double` (computed)

Model method signatures (suggested)
- `String addItem(Sandwich s, int quantity)`
- `CartItem incrementQuantity(String cartItemId)`
- `CartItem? decrementQuantity(String cartItemId)`
- `CartItem? updateQuantity(String cartItemId, int newQuantity)`
- `EditResult editItem(String cartItemId, Sandwich newConfig)`
- `CartItem removeItem(String cartItemId)`
- `CartItem restoreItem(CartItem item)`

Equality helper
- `bool cartItemEquals(CartItem a, CartItem b)` — same type, size and bread.

## User Stories

1. Shopper
- As a shopper, I can increase an item's quantity from the cart to order more.
- As a shopper, I can decrease or remove an item and Undo the removal.
- As a shopper, I can edit an item's size or bread so my order is correct.

2. Power user
- As a power user, I want merges to combine quantities when edits produce duplicate configurations.

3. QA engineer
- As QA, I need stable keys to write deterministic tests for increment/decrement/remove/edit/Undo.

4. Developer
- As a developer, I want the Cart model to return prior state to implement Undo reliably.

## Acceptance Criteria (Given/When/Then)

1. Increment quantity
- Given a cart item qty=1
- When increment pressed (`cart_item_<id>_increment`)
- Then quantity becomes 2 and `cart_total_price` updates.

2. Decrement (non-removing)
- Given item qty=3
- When decrement pressed
- Then quantity becomes 2 and totals recalc.

3. Decrement to zero removes and offers Undo
- Given item qty=1
- When decrement pressed
- Then item removed and `cart_undo_snack` appears; Undo restores item and totals.

4. Remove & Undo
- Given an item
- When remove pressed (`cart_item_<id>_remove`)
- Then item removed and `cart_undo_snack` appears; Undo restores item.

5. Edit item — non-merge
- Given item A and no identical existing item
- When edit saved
- Then A updates in place and totals update. `editItem` returns `{mergedIntoId: null, updatedId: <id>}`.

6. Edit item — merge
- Given A(qty=2) and B(qty=1) and editing A to match B
- When save
- Then B.qty becomes 3, A removed, SnackBar shows merge with Undo, Undo restores A and original B qty.

7. Pricing correctness
- After any update, `cart_total_price` equals sum(quantity * PricingRepository.calculatePrice(quantity, isFootlong)).

8. Determinism for tests
- All controls required by tests are present with the specified keys.

9. Accessibility
- Controls expose semantics and are keyboard-navigable.

10. No regressions
- Existing unrelated tests pass after implementation.

## Edge Cases (to test)
- Rapid tapping of increment/decrement should maintain consistent state.
- Editing while Undo SnackBar for a prior removal is active.
- Multiple sequential merges.
- Large quantities (e.g., 1000) remain performant.
- Direct input of negative/zero quantities is clamped.

## Test Plan

1. Unit tests (Cart model)
- addItem, increment, decrement, updateQuantity, editItem, merge, remove/restore and pricing correctness (with mocked `PricingRepository`).

2. Widget tests
- Render `cart_screen`, verify `cart_item_count` and `cart_total_price`.
- Test increment/decrement, remove -> Undo, and edit modal flows (edit -> update and edit -> merge + Undo).

3. Integration smoke
- Add items from Order screen, open cart, perform edits/removals, verify totals.

4. Keys
- Tests must use the keys defined in the Test keys section.

## Subtasks

1. Draft requirements doc (this file)
2. Review asset naming and ensure `lib/models/sandwich.dart` and tests match the pattern (e.g., `veggieDelight_six_inch.png`).
3. Implement `cart_screen` and row controls with keys.
4. Implement Cart API changes (updateQuantity, editItem with merge metadata, remove/restore).
5. Implement Edit Item modal and merge UX.
6. Implement remove + Undo SnackBar and Undo restore logic.
7. Add unit and widget tests per Test Plan.
8. Accessibility checks and small polish.
9. Update README/docs describing merge/Undo behavior and the keys available for tests.

## Implementation Notes
- Use stable `cartItem.id` generated at add-time and use it for keys to avoid flakiness.
- Return rich result objects from `editItem` to let UI respond (merge vs in-place update).
- Maintain small undo stack (last action) storing prior state for restore.
- Inject a mocked `PricingRepository` in tests for deterministic prices.
- Centralize image filename generation in a helper: `sandwichImageFileName(Sandwich s) => '${s.typeName}_${s.isFootlong ? "footlong" : "six_inch"}.png'`.

## Deliverables
- This Markdown document (`requiremetns.md`).
- Stable key definitions and the CartItem API contract for implementers.

## Next steps
- Confirm whether to (A) update code/tests to match the `six_inch` asset names or (B) begin implementing the cart-edit UI and model changes. Indicate choice and I'll start the corresponding todo.

---

File created as `requiremetns.md` at project root. Use the listed keys in tests and implement the Cart API as specified.

## Profile Screen — Requirements & AI prompt

### Overview
Add a lightweight Profile screen where a user can view and edit simple profile fields (name, email, phone). No authentication or persistence is required for this exercise — the screen should validate inputs minimally and expose stable widget keys for testing.

### Acceptance criteria
- The Profile screen is reachable from the Order screen via a visible link/button with key `profile_button`.
- The screen shows a header `Profile` and form fields for `Name`, `Email`, and `Phone` with keys `profile_name`, `profile_email`, and `profile_phone` respectively.
- The `Save` button (key `profile_save`) validates the email format and shows a SnackBar `Profile saved` when the form is valid.
- The `Cancel` button (key `profile_cancel`) returns to the previous screen without saving.

### Test keys
- `profile_button` — link on the Order screen that opens the Profile screen
- `profile_name` — TextFormField for the user's name
- `profile_email` — TextFormField for the user's email
- `profile_phone` — TextFormField for the user's phone
- `profile_save` — Save button
- `profile_cancel` — Cancel button

### Minimal validation
- `Name`: non-empty
- `Email`: basic regex/contains '@'
- `Phone`: optional, allow digits and punctuation

### AI Assistant Prompt (for implementation)
"Implement a simple Profile screen for the Sandwich Shop app. Create `lib/views/profile_screen.dart` containing a `ProfileScreen` widget with a form (Name, Email, Phone) using `TextFormField`s and a `Save` and `Cancel` button. Add stable widget keys as specified above. Wire the `Save` button to validate (non-empty name, email contains '@') and show a SnackBar 'Profile saved' when valid, otherwise show inline validation errors. Add a route `/profile` in `MaterialApp` and add a visible `profile_button` on the Order screen that navigates to the profile route. Also write a widget test that taps the profile button, fills in valid values, taps Save, and asserts the SnackBar is shown." 

### Notes
- No backend or persistence needed — form state may be local to the widget.
- Keep styling consistent with `app_styles.dart` and re-use `StyledButton` for actions where appropriate.

## Navigation & Drawer — Requirements (implemented changes)

This file has been updated to reflect navigation-related work completed in the codebase. The following summarizes what was implemented during the recent changes and how it maps back to the requirements above.

Implemented items
- `MainScaffold` (`lib/views/main_scaffold.dart`) — a shared scaffold that centralizes AppBar and navigation. It provides:
   - Hidden `Drawer` on narrow screens with an AppBar menu action.
   - Permanent side navigation on wide screens (>= 900px).
- Drawer navigation entries for About and Profile are wired to routes and use the `MainScaffold`.
- `AboutScreen`, `ProfileScreen`, `CartScreen`, and `CheckoutScreen` now use `MainScaffold` so the Drawer is available consistently.
- Reusable `StyledButton` extracted to `lib/views/styled_button.dart` and re-exported from `lib/main.dart` to retain compatibility with tests.
- Widget tests added/updated: `test/views/profile_screen_test.dart` verifies navigation to Profile and the Save flow; existing cart tests still pass.

Notes / remaining alignment tasks
- The original Cart model is still index-based. The requirements recommend migrating to id-based `CartItem` with stable ids for robust undo/merge semantics. That migration remains outstanding.
- Drawer keys: please confirm if you want the exact test keys (`nav_drawer_button`, `drawer_home`, `drawer_cart`, `drawer_about`, `drawer_profile`) added to every Drawer/ListTile. I added the Drawer and wiring, but some items may not yet have the exact test key names — I can update them to match the requirements precisely on request.

Suggested next steps (to close the loop on requirements)
1. Migrate `Cart` to id-based API (`cartItem.id`) and update UI/tests to rely on id-based keys.
2. Promote `Cart` to app-level state (Provider/InheritedWidget) so Drawer-initiated Cart navigation can access the shared Cart instance.
3. Add Drawer open/close tests and wide-screen permanent navigation tests as listed in the Navigation section above.


