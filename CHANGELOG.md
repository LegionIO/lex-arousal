# Changelog

## [0.1.1] - 2026-03-18

### Added
- `SOURCE_MULTIPLIERS` constant — maps arousal sources to impact multipliers (threat: 1.5x, emergency: 1.8x, routine: 0.7x, etc.)
- `stimulate` now applies source-specific multiplier to the boost amount, making threats spike arousal more than routine signals

## [0.1.0] - 2026-03-13

### Added
- Initial release: Yerkes-Dodson arousal model with EMA tracking
- Performance computation via inverted-U Gaussian curve
- Task complexity-specific optimal arousal levels
- Arousal guidance (boost/throttle/maintain)
- Standalone Client
