# frozen_string_literal: true

module Legion
  module Extensions
    module Arousal
      module Helpers
        class ArousalModel
          include Constants

          attr_reader :arousal, :arousal_history, :performance_last

          def initialize
            @arousal = DEFAULT_AROUSAL
            @arousal_history = []
            @performance_last = 0.0
          end

          def stimulate(amount:, source: :unknown)
            boost = amount || BOOST_FACTOR
            multiplier = SOURCE_MULTIPLIERS.fetch(source, SOURCE_MULTIPLIERS[:unknown])
            raw = @arousal + (boost.to_f.clamp(0.0, 1.0) * multiplier)
            update_arousal(raw, source: source)
          end

          def calm(amount:)
            reduction = amount || CALM_FACTOR
            raw = @arousal - reduction.to_f.clamp(0.0, 1.0)
            update_arousal(raw, source: :calm)
          end

          def decay
            delta = (@arousal - DEFAULT_AROUSAL) * DECAY_RATE
            raw = @arousal - delta
            update_arousal(raw, source: :decay)
          end

          def performance(task_complexity: :moderate)
            optimal = optimal_for(task_complexity)
            diff = @arousal - optimal
            @performance_last = Math.exp(-PERFORMANCE_SENSITIVITY * (diff**2))
            @performance_last
          end

          def arousal_label
            AROUSAL_LABELS.each do |range, label|
              return label if range.cover?(@arousal)
            end
            :dormant
          end

          def optimal_for(complexity)
            TASK_COMPLEXITIES.fetch(complexity, OPTIMAL_AROUSAL_DEFAULT)
          end

          def to_h
            {
              arousal:          @arousal,
              label:            arousal_label,
              performance_last: @performance_last,
              history_size:     @arousal_history.size
            }
          end

          private

          def update_arousal(raw, source: :unknown)
            clamped = raw.clamp(AROUSAL_FLOOR, AROUSAL_CEILING)
            @arousal = (AROUSAL_ALPHA * clamped) + ((1.0 - AROUSAL_ALPHA) * @arousal)
            record_history(source)
            @arousal
          end

          def record_history(source)
            @arousal_history << { arousal: @arousal, source: source, at: Time.now.utc }
            @arousal_history.shift while @arousal_history.size > MAX_AROUSAL_HISTORY
          end
        end
      end
    end
  end
end
