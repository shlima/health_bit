RSpec.describe HealthBit::CheckError do
  describe '#to_s' do
    subject do
      described_class.new('foo', exception: exception)
    end

    let(:exception) do
      RuntimeError.new
    end

    context 'when short format' do
      let(:expectation) do
        'Check <foo> failed'
      end

      it 'works with the empty argv' do
        expect(subject.to_s).to eq(expectation)
      end

      it 'works with the short argv' do
        expect(subject.to_s(described_class::FORMAT_SHORT)).to eq(expectation)
      end
    end

    context 'when full format' do
      it 'works' do
        expect(subject.to_s(described_class::FORMAT_FULL)).to include(String(exception.class))
      end
    end

    context 'when full format with empty exception' do
      let(:exception) do
        nil
      end

      it 'works' do
        expect { subject.to_s(described_class::FORMAT_FULL) }.not_to raise_error
      end
    end
  end
end
