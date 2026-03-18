# frozen_string_literal: true

RSpec.describe Legion::Extensions::Arousal::Helpers::ArousalModel do
  let(:model) { described_class.new }

  describe '#initialize' do
    it 'starts at the default arousal level' do
      expect(model.arousal).to be_within(0.001).of(Legion::Extensions::Arousal::Helpers::Constants::DEFAULT_AROUSAL)
    end

    it 'starts with empty history' do
      expect(model.arousal_history).to be_empty
    end

    it 'starts with zero performance' do
      expect(model.performance_last).to eq(0.0)
    end
  end

  describe '#stimulate' do
    it 'increases arousal' do
      before = model.arousal
      model.stimulate(amount: 0.3, source: :test)
      expect(model.arousal).to be > before
    end

    it 'records the source in history' do
      model.stimulate(amount: 0.2, source: :external)
      expect(model.arousal_history.last[:source]).to eq(:external)
    end

    it 'clamps arousal at ceiling' do
      10.times { model.stimulate(amount: 1.0, source: :test) }
      expect(model.arousal).to be <= 1.0
    end

    it 'returns the new arousal level' do
      result = model.stimulate(amount: 0.2, source: :test)
      expect(result).to eq(model.arousal)
    end

    it 'applies a higher multiplier for threat sources' do
      model_a = described_class.new
      model_b = described_class.new
      model_a.stimulate(amount: 0.2, source: :threat)
      model_b.stimulate(amount: 0.2, source: :routine)
      expect(model_a.arousal).to be > model_b.arousal
    end

    it 'applies emergency multiplier (1.8x)' do
      model_a = described_class.new
      model_b = described_class.new
      model_a.stimulate(amount: 0.2, source: :emergency)
      model_b.stimulate(amount: 0.2, source: :unknown)
      expect(model_a.arousal).to be > model_b.arousal
    end

    it 'uses 1.0 multiplier for unrecognized sources' do
      model_a = described_class.new
      model_b = described_class.new
      model_a.stimulate(amount: 0.2, source: :something_new)
      model_b.stimulate(amount: 0.2, source: :unknown)
      expect(model_a.arousal).to eq(model_b.arousal)
    end
  end

  describe '#calm' do
    before { model.stimulate(amount: 0.5, source: :setup) }

    it 'decreases arousal' do
      before = model.arousal
      model.calm(amount: 0.2)
      expect(model.arousal).to be < before
    end

    it 'clamps arousal at floor' do
      10.times { model.calm(amount: 1.0) }
      expect(model.arousal).to be >= 0.0
    end

    it 'returns the new arousal level' do
      result = model.calm(amount: 0.1)
      expect(result).to eq(model.arousal)
    end
  end

  describe '#decay' do
    it 'moves arousal toward the default resting level from above' do
      model.stimulate(amount: 0.5, source: :setup)
      raised = model.arousal
      model.decay
      # After stimulating above default, decay should lower it (move toward default)
      expect(model.arousal).to be < raised
    end

    it 'records a decay entry in history' do
      model.decay
      expect(model.arousal_history.last[:source]).to eq(:decay)
    end
  end

  describe '#performance' do
    it 'returns a value between 0 and 1' do
      perf = model.performance
      expect(perf).to be >= 0.0
      expect(perf).to be <= 1.0
    end

    it 'returns highest performance near the optimal arousal' do
      model.stimulate(amount: 0.2, source: :test)
      perf_near_optimal = model.performance(task_complexity: :moderate)

      model2 = described_class.new
      10.times { model2.stimulate(amount: 0.8, source: :test) }
      perf_far_from_optimal = model2.performance(task_complexity: :moderate)

      expect(perf_near_optimal).to be >= perf_far_from_optimal
    end

    it 'uses complexity-specific optimal for simple tasks' do
      perf_simple = model.performance(task_complexity: :simple)
      expect(perf_simple).to be_a(Float)
    end

    it 'updates performance_last' do
      model.performance(task_complexity: :moderate)
      expect(model.performance_last).to be > 0.0
    end
  end

  describe '#arousal_label' do
    it 'returns :dormant for near-zero arousal' do
      10.times { model.calm(amount: 1.0) }
      expect(model.arousal_label).to eq(:dormant)
    end

    it 'returns :panic for high arousal' do
      10.times { model.stimulate(amount: 1.0, source: :test) }
      expect(model.arousal_label).to eq(:panic)
    end

    it 'returns a symbol for any arousal level' do
      expect(model.arousal_label).to be_a(Symbol)
    end
  end

  describe '#optimal_for' do
    it 'returns the correct optimal for each complexity' do
      constants = Legion::Extensions::Arousal::Helpers::Constants
      expect(model.optimal_for(:trivial)).to eq(constants::TASK_COMPLEXITIES[:trivial])
      expect(model.optimal_for(:moderate)).to eq(constants::TASK_COMPLEXITIES[:moderate])
      expect(model.optimal_for(:extreme)).to eq(constants::TASK_COMPLEXITIES[:extreme])
    end

    it 'returns the default when complexity is unknown' do
      expect(model.optimal_for(:unknown)).to eq(Legion::Extensions::Arousal::Helpers::Constants::OPTIMAL_AROUSAL_DEFAULT)
    end
  end

  describe '#arousal_history cap' do
    it 'does not exceed MAX_AROUSAL_HISTORY entries' do
      max = Legion::Extensions::Arousal::Helpers::Constants::MAX_AROUSAL_HISTORY
      (max + 10).times { model.stimulate(amount: 0.01, source: :test) }
      expect(model.arousal_history.size).to eq(max)
    end
  end

  describe '#to_h' do
    it 'includes arousal, label, performance_last, and history_size' do
      h = model.to_h
      expect(h).to have_key(:arousal)
      expect(h).to have_key(:label)
      expect(h).to have_key(:performance_last)
      expect(h).to have_key(:history_size)
    end

    it 'reflects the current state' do
      model.stimulate(amount: 0.2, source: :test)
      h = model.to_h
      expect(h[:arousal]).to eq(model.arousal)
      expect(h[:history_size]).to eq(model.arousal_history.size)
    end
  end
end
