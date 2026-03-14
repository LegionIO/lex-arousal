# lex-arousal

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Yerkes-Dodson arousal regulation for brain-modeled agentic AI. Models the inverted-U relationship between arousal level and performance quality: too little arousal produces poor performance from under-engagement; too much produces poor performance from anxiety and overload. Optimal arousal depends on task complexity.

## Gem Info

- **Gem name**: `lex-arousal`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Arousal`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/arousal/
  arousal.rb              # Main extension module
  version.rb              # VERSION = '0.1.0'
  client.rb               # Client wrapper
  helpers/
    constants.rb          # Arousal bounds, optimal levels, task complexity map, labels
    arousal_model.rb      # ArousalModel — EMA-tracked arousal, performance computation
  runners/
    arousal.rb            # Runner module with 6 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
DEFAULT_AROUSAL         = 0.3
AROUSAL_ALPHA           = 0.15    # EMA alpha
DECAY_RATE              = 0.05    # per-tick decay toward floor
OPTIMAL_AROUSAL_SIMPLE  = 0.7     # optimal for simple tasks
OPTIMAL_AROUSAL_COMPLEX = 0.4     # optimal for complex tasks
OPTIMAL_AROUSAL_DEFAULT = 0.5
PERFORMANCE_SENSITIVITY = 4.0     # how sharply performance drops away from optimal
BOOST_FACTOR            = 0.2     # default stimulate amount
CALM_FACTOR             = 0.15    # default calm amount
AROUSAL_FLOOR           = 0.0
AROUSAL_CEILING         = 1.0
MAX_AROUSAL_HISTORY     = 200

TASK_COMPLEXITIES = {
  trivial: 0.8, simple: 0.7, moderate: 0.5, complex: 0.4, extreme: 0.3
}
AROUSAL_LABELS = {
  (0.8..) => :panic, (0.6...0.8) => :high,
  (0.4...0.6) => :optimal, (0.2...0.4) => :low, (..0.2) => :dormant
}
```

## Runners

### `Runners::Arousal`

All methods delegate to a private `@arousal_model` (`Helpers::ArousalModel` instance).

- `stimulate(amount: nil, source: :unknown)` — increase arousal by amount (default `BOOST_FACTOR`)
- `calm(amount: nil)` — decrease arousal by amount (default `CALM_FACTOR`)
- `update_arousal` — decay arousal toward floor, returns current performance
- `check_performance(task_complexity: :moderate)` — compute performance given current arousal and task complexity
- `arousal_status` — current arousal, label, performance, and history size
- `arousal_guidance(task_complexity: :moderate)` — returns `:boost`, `:throttle`, or `:maintain` based on gap between current and optimal arousal

## Helpers

### `Helpers::ArousalModel`
EMA-tracked arousal with history. `performance` uses Gaussian-shaped inverted-U: `exp(-PERFORMANCE_SENSITIVITY * (arousal - optimal)^2)`. `optimal_for(task_complexity)` returns `TASK_COMPLEXITIES[task_complexity]`.

## Integration Points

No actor defined — callers drive the arousal lifecycle. Integrates with lex-emotion: high arousal feeds into emotional intensity signals. Works alongside lex-attention: high arousal narrows the attentional spotlight; low arousal allows broader scanning. The `arousal_guidance` output (`:boost`/`:throttle`/`:maintain`) can wire into lex-tick's tick mode selection — throttle → consider moving toward dormant; boost → move toward full_active.

## Development Notes

- Arousal is additive/subtractive (stimulate/calm), not EMA — EMA is used only for direction in ArousalModel, actual arousal is a direct accumulation with decay
- `PERFORMANCE_SENSITIVITY = 4.0` makes the inverted-U fairly sharp: deviating 0.3 from optimal reduces performance to ~exp(-0.36) ≈ 0.7
- Gap threshold in `compute_guidance` is ±0.15: within this range the guidance is `:maintain`
- The `source:` parameter on `stimulate` is logged but not used for differential processing
