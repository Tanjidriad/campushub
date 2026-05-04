# CampusHub UX premium baseline (post-audit)

Reference snapshot before premium upgrade implementation.

## Strengths

- Home IA: highlights, categories, education filter, recommended, featured, staff picks, deals, latest grid.
- Pinterest-style masonry (`StaggeredListingCard`), shimmer loading, pull-to-refresh.
- Theme tokens via `AppColors` / `AppPalette`, Material 3.

## Gaps addressed in upgrade

- Categories: icon grid → pastel gradient cards.
- Motion: press feedback, staggered entry, wishlist pulse, bottom-nav active pill.
- Typography: section titles (display font + tracking), price/title/date hierarchy.
- Search: rotating hints, persisted recent searches on home.
- Highlights: frosted-glass detail panel.
- Staff picks: hero first row + rank badges.
- Listing cards: condition chip, image count, seller avatar, trending badge.
- Personalization: time-based greeting, “because you searched”, recently viewed.
- Dark: OLED-true-black option via theme extension + preference.
