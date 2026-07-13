# Mobile Hero Experience Card Design

## Problem

At viewport widths up to 640px, the homepage hero renders the `13+ NĂM KINH NGHIỆM` card over the top-right of the hero photo. The persisted hero image places the speaker's face near that same area, so the card obscures the face at the reported 399×761 viewport. The browser console warnings in the report do not affect this layout.

## Root Cause

The mobile hero remains an absolutely positioned composition. The experience card starts at `top: 8px`, while the photo starts at `top: 24px`. Their vertical ranges therefore overlap by design. Because replacement images can place a face anywhere in the photo, reframing only the current image would not prevent the bug from recurring.

## Considered Approaches

1. Move the current photo down just enough to expose the current face. This is the smallest CSS change, but another image with a different focal point could still be covered.
2. Reserve a separate mobile lane for the experience card above the photo. This guarantees that the card and photo do not intersect and is the selected approach.
3. Persist a new crop or zoom for the hero image. The crop state is shared across breakpoints, so this could degrade desktop framing and would only solve the current image.

## Selected Design

The desktop and tablet composition remains unchanged. At widths up to 640px:

- The experience card keeps its current `top: 8px` and `right: 6px` alignment at the top of `.gp-hero-visual`.
- A 92px lane is reserved above the photo. The current card ends at approximately 79px, leaving at least 13px of separation.
- The photo starts at `top: 92px` and keeps its existing mobile height of 255px.
- The hero visual height becomes 350px, containing the photo through 347px with 3px remaining.
- The logo badge and `300+` card keep their current bottom anchoring and intentional overlap with the lower part of the photo.
- A dedicated class identifies the experience card so the responsive contract is explicit and testable.

The resulting invariant is: the bottom edge of the experience card must be above the top edge of the hero photo at mobile widths. The fix does not depend on where a face appears in the image.

## Scope

Only the homepage hero markup and its mobile CSS are in scope. Image data, desktop/tablet geometry, typography, animation, other homepage sections, and the reported console warnings are unchanged.

## Verification

Before implementation, add a failing static regression check for the mobile contract. It must verify that:

- the experience card has its dedicated class;
- the max-width 640px rules reserve a non-overlapping lane above the photo;
- the mobile hero height contains both the lane and the existing 255px photo;
- the desktop inline geometry is unchanged.

After the CSS change, rerun the regression check, the repository's existing static verification, HTML sanity checks, and a fresh diff review. Browser-control visual verification should be run if a browser backend is available; otherwise the supplied screenshot, decoded persisted image, and deterministic layout bounds remain the visual evidence.
