# lex-arousal

Yerkes-Dodson arousal regulation for brain-modeled agentic AI.

## What It Does

Models the inverted-U relationship between arousal and performance. An agent that is too calm underperforms due to disengagement; an agent that is too aroused underperforms due to anxiety and cognitive overload. The optimal arousal level depends on task complexity — simple tasks benefit from higher arousal, complex tasks require lower arousal for peak performance.

## Core Concept: Inverted-U Performance

Performance is computed as a Gaussian centered on the optimal arousal for the given task:

```
performance = exp(-PERFORMANCE_SENSITIVITY * (arousal - optimal)^2)
```

Optimal arousal: simple=0.7, moderate=0.5, complex=0.4, extreme=0.3.

## Usage

```ruby
client = Legion::Extensions::Arousal::Client.new

# Stimulate (e.g., due to an urgent alert)
client.stimulate(amount: 0.3, source: :threat_detected)
# => { arousal: 0.6, label: :high }

# Check if current arousal is optimal for the task
client.check_performance(task_complexity: :complex)
# => { performance: 0.71, arousal: 0.6, optimal_arousal: 0.4 }

# Get actionable guidance
client.arousal_guidance(task_complexity: :complex)
# => { guidance: :throttle, arousal: 0.6, optimal_arousal: 0.4 }

# Calm down
client.calm(amount: 0.15)

# Decay tick (call periodically)
client.update_arousal
```

## Integration

Wire `arousal_guidance` into lex-tick mode selection: `:boost` suggests moving toward `full_active` mode; `:throttle` suggests moving toward `dormant`. High arousal feeds into lex-emotion's intensity signals.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
