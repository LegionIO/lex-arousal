# frozen_string_literal: true

require 'legion/extensions/arousal/client'

RSpec.describe Legion::Extensions::Arousal::Runners::Arousal do
  let(:client) { Legion::Extensions::Arousal::Client.new }

  describe '#stimulate' do
    it 'returns success: true' do
      result = client.stimulate
      expect(result[:success]).to be(true)
    end

    it 'returns the new arousal level' do
      result = client.stimulate(amount: 0.2, source: :test)
      expect(result[:arousal]).to be_a(Float)
    end

    it 'returns a label' do
      result = client.stimulate
      expect(result[:label]).to be_a(Symbol)
    end

    it 'returns the source' do
      result = client.stimulate(source: :external_event)
      expect(result[:source]).to eq(:external_event)
    end

    it 'increases arousal above default' do
      result = client.stimulate(amount: 0.4)
      expect(result[:arousal]).to be > Legion::Extensions::Arousal::Helpers::Constants::DEFAULT_AROUSAL
    end
  end

  describe '#calm' do
    before { client.stimulate(amount: 0.5) }

    it 'returns success: true' do
      expect(client.calm[:success]).to be(true)
    end

    it 'returns the new arousal level' do
      result = client.calm(amount: 0.1)
      expect(result[:arousal]).to be_a(Float)
    end

    it 'returns a label' do
      expect(client.calm[:label]).to be_a(Symbol)
    end
  end

  describe '#update_arousal' do
    it 'returns success: true' do
      expect(client.update_arousal[:success]).to be(true)
    end

    it 'returns arousal, label, and performance' do
      result = client.update_arousal
      expect(result).to have_key(:arousal)
      expect(result).to have_key(:label)
      expect(result).to have_key(:performance)
    end

    it 'returns performance between 0 and 1' do
      result = client.update_arousal
      expect(result[:performance]).to be_between(0.0, 1.0)
    end
  end

  describe '#check_performance' do
    it 'returns success: true' do
      expect(client.check_performance[:success]).to be(true)
    end

    it 'returns performance, arousal, optimal_arousal, and task_complexity' do
      result = client.check_performance(task_complexity: :simple)
      expect(result).to have_key(:performance)
      expect(result).to have_key(:arousal)
      expect(result).to have_key(:optimal_arousal)
      expect(result[:task_complexity]).to eq(:simple)
    end

    it 'reflects the optimal arousal for the given complexity' do
      result_simple  = client.check_performance(task_complexity: :simple)
      result_extreme = client.check_performance(task_complexity: :extreme)
      expect(result_simple[:optimal_arousal]).to be > result_extreme[:optimal_arousal]
    end
  end

  describe '#arousal_status' do
    it 'returns success: true' do
      expect(client.arousal_status[:success]).to be(true)
    end

    it 'returns arousal, label, performance, and history_size' do
      result = client.arousal_status
      expect(result).to have_key(:arousal)
      expect(result).to have_key(:label)
      expect(result).to have_key(:performance)
      expect(result).to have_key(:history_size)
    end
  end

  describe '#arousal_guidance' do
    it 'returns success: true' do
      expect(client.arousal_guidance[:success]).to be(true)
    end

    it 'returns guidance as a symbol' do
      result = client.arousal_guidance
      expect(result[:guidance]).to be_a(Symbol)
    end

    it 'returns :throttle when arousal is well above optimal' do
      5.times { client.stimulate(amount: 1.0) }
      result = client.arousal_guidance(task_complexity: :extreme)
      expect(result[:guidance]).to eq(:throttle)
    end

    it 'returns :boost when arousal is well below optimal' do
      10.times { client.calm(amount: 1.0) }
      result = client.arousal_guidance(task_complexity: :trivial)
      expect(result[:guidance]).to eq(:boost)
    end

    it 'returns :maintain when near optimal' do
      result = client.arousal_guidance(task_complexity: :moderate)
      expect(%i[maintain throttle boost]).to include(result[:guidance])
    end

    it 'includes optimal_arousal and task_complexity' do
      result = client.arousal_guidance(task_complexity: :complex)
      expect(result[:optimal_arousal]).to eq(0.4)
      expect(result[:task_complexity]).to eq(:complex)
    end
  end
end
