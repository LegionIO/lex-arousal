# frozen_string_literal: true

module Legion
  module Extensions
    module Arousal
      module Runners
        module Arousal
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def stimulate(amount: nil, source: :unknown, **)
            model = arousal_model
            amount ||= Helpers::Constants::BOOST_FACTOR
            new_level = model.stimulate(amount: amount, source: source)
            Legion::Logging.debug "[arousal] stimulate: source=#{source} amount=#{amount.round(2)} level=#{new_level.round(3)}"
            {
              success: true,
              arousal: new_level,
              label:   model.arousal_label,
              source:  source
            }
          end

          def calm(amount: nil, **)
            model = arousal_model
            amount ||= Helpers::Constants::CALM_FACTOR
            new_level = model.calm(amount: amount)
            Legion::Logging.debug "[arousal] calm: amount=#{amount.round(2)} level=#{new_level.round(3)}"
            {
              success: true,
              arousal: new_level,
              label:   model.arousal_label
            }
          end

          def update_arousal(**)
            model = arousal_model
            model.decay
            perf = model.performance
            Legion::Logging.debug "[arousal] update: level=#{model.arousal.round(3)} label=#{model.arousal_label} perf=#{perf.round(3)}"
            {
              success:     true,
              arousal:     model.arousal,
              label:       model.arousal_label,
              performance: perf
            }
          end

          def check_performance(task_complexity: :moderate, **)
            model = arousal_model
            perf = model.performance(task_complexity: task_complexity)
            optimal = model.optimal_for(task_complexity)
            msg = "[arousal] performance: complexity=#{task_complexity} " \
                  "arousal=#{model.arousal.round(3)} optimal=#{optimal} perf=#{perf.round(3)}"
            Legion::Logging.debug msg
            {
              success:         true,
              performance:     perf,
              arousal:         model.arousal,
              optimal_arousal: optimal,
              task_complexity: task_complexity
            }
          end

          def arousal_status(**)
            model = arousal_model
            perf = model.performance
            Legion::Logging.debug "[arousal] status: level=#{model.arousal.round(3)} label=#{model.arousal_label}"
            {
              success:      true,
              arousal:      model.arousal,
              label:        model.arousal_label,
              performance:  perf,
              history_size: model.arousal_history.size
            }
          end

          def arousal_guidance(task_complexity: :moderate, **)
            model = arousal_model
            current = model.arousal
            optimal = model.optimal_for(task_complexity)
            perf = model.performance(task_complexity: task_complexity)
            guidance = compute_guidance(current, optimal)
            Legion::Logging.debug "[arousal] guidance: complexity=#{task_complexity} current=#{current.round(3)} optimal=#{optimal} guidance=#{guidance}"
            {
              success:         true,
              guidance:        guidance,
              arousal:         current,
              optimal_arousal: optimal,
              performance:     perf,
              task_complexity: task_complexity
            }
          end

          private

          def arousal_model
            @arousal_model ||= Helpers::ArousalModel.new
          end

          def compute_guidance(current, optimal)
            gap = current - optimal
            if gap > 0.15
              :throttle
            elsif gap < -0.15
              :boost
            else
              :maintain
            end
          end
        end
      end
    end
  end
end
