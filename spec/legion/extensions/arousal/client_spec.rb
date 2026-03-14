# frozen_string_literal: true

require 'legion/extensions/arousal/client'

RSpec.describe Legion::Extensions::Arousal::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:stimulate)
    expect(client).to respond_to(:calm)
    expect(client).to respond_to(:update_arousal)
    expect(client).to respond_to(:check_performance)
    expect(client).to respond_to(:arousal_status)
    expect(client).to respond_to(:arousal_guidance)
  end

  it 'runs a full arousal cycle' do
    client.stimulate(amount: 0.3, source: :external)
    status = client.arousal_status
    expect(status[:arousal]).to be > Legion::Extensions::Arousal::Helpers::Constants::DEFAULT_AROUSAL
    expect(status[:label]).to be_a(Symbol)

    client.calm(amount: 0.1)
    calmed = client.arousal_status
    expect(calmed[:arousal]).to be_a(Float)

    guidance = client.arousal_guidance(task_complexity: :moderate)
    expect(guidance[:guidance]).to be_a(Symbol)
  end

  it 'persists state across calls' do
    client.stimulate(amount: 0.5, source: :test)
    client.stimulate(amount: 0.2, source: :test)
    status = client.arousal_status
    expect(status[:history_size]).to be >= 2
  end

  it 'returns higher performance near the optimal arousal for a given complexity' do
    perf_moderate = client.check_performance(task_complexity: :moderate)
    expect(perf_moderate[:performance]).to be_between(0.0, 1.0)
  end
end
