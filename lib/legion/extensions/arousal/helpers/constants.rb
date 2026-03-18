# frozen_string_literal: true

module Legion
  module Extensions
    module Arousal
      module Helpers
        module Constants
          DEFAULT_AROUSAL          = 0.3
          AROUSAL_ALPHA            = 0.15
          DECAY_RATE               = 0.05
          OPTIMAL_AROUSAL_SIMPLE   = 0.7
          OPTIMAL_AROUSAL_COMPLEX  = 0.4
          OPTIMAL_AROUSAL_DEFAULT  = 0.5
          PERFORMANCE_SENSITIVITY  = 4.0
          BOOST_FACTOR             = 0.2
          CALM_FACTOR              = 0.15
          AROUSAL_FLOOR            = 0.0
          AROUSAL_CEILING          = 1.0
          MAX_AROUSAL_HISTORY      = 200

          SOURCE_MULTIPLIERS = {
            threat:    1.5,
            emergency: 1.8,
            conflict:  1.3,
            novelty:   1.2,
            social:    1.1,
            routine:   0.7,
            scheduled: 0.6,
            decay:     1.0,
            calm:      1.0,
            unknown:   1.0
          }.freeze

          TASK_COMPLEXITIES = {
            trivial:  0.8,
            simple:   0.7,
            moderate: 0.5,
            complex:  0.4,
            extreme:  0.3
          }.freeze

          AROUSAL_LABELS = {
            (0.8..)     => :panic,
            (0.6...0.8) => :high,
            (0.4...0.6) => :optimal,
            (0.2...0.4) => :low,
            (..0.2)     => :dormant
          }.freeze
        end
      end
    end
  end
end
