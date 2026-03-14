# frozen_string_literal: true

RSpec.describe Legion::Extensions::Arousal::Helpers::Constants do
  describe 'DEFAULT_AROUSAL' do
    it 'is 0.3' do
      expect(described_class::DEFAULT_AROUSAL).to eq(0.3)
    end
  end

  describe 'AROUSAL_FLOOR and AROUSAL_CEILING' do
    it 'floor is 0.0' do
      expect(described_class::AROUSAL_FLOOR).to eq(0.0)
    end

    it 'ceiling is 1.0' do
      expect(described_class::AROUSAL_CEILING).to eq(1.0)
    end
  end

  describe 'TASK_COMPLEXITIES' do
    it 'includes all expected complexity levels' do
      expect(described_class::TASK_COMPLEXITIES.keys).to contain_exactly(:trivial, :simple, :moderate, :complex, :extreme)
    end

    it 'trivial has the highest optimal arousal' do
      expect(described_class::TASK_COMPLEXITIES[:trivial]).to be > described_class::TASK_COMPLEXITIES[:extreme]
    end

    it 'extreme has the lowest optimal arousal' do
      expect(described_class::TASK_COMPLEXITIES[:extreme]).to eq(0.3)
    end
  end

  describe 'AROUSAL_LABELS' do
    it 'covers the full 0.0..1.0 range' do
      test_values = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]
      test_values.each do |v|
        matched = described_class::AROUSAL_LABELS.any? { |range, _| range.cover?(v) }
        expect(matched).to be(true), "Expected #{v} to match a label range"
      end
    end

    it 'maps values >= 0.8 to :panic' do
      range, label = described_class::AROUSAL_LABELS.find { |r, _| r.cover?(0.9) }
      expect(label).to eq(:panic)
      expect(range).to cover(0.9)
    end

    it 'maps values in 0.4..0.6 to :optimal' do
      range, label = described_class::AROUSAL_LABELS.find { |r, _| r.cover?(0.5) }
      expect(label).to eq(:optimal)
      expect(range).to cover(0.5)
    end
  end

  describe 'OPTIMAL_AROUSAL_SIMPLE and OPTIMAL_AROUSAL_COMPLEX' do
    it 'simple optimal is higher than complex optimal' do
      expect(described_class::OPTIMAL_AROUSAL_SIMPLE).to be > described_class::OPTIMAL_AROUSAL_COMPLEX
    end
  end
end
