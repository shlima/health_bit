RSpec.describe HealthBit::Check do
  describe '#call' do
    context 'when fail' do
      let(:subjects) do
        [
          described_class.new('foo', -> { nil }),
          described_class.new('foo', -> { false }),
          described_class.new('foo', -> { raise }),
          described_class.new('foo', Class.new { def self.call ; false ; end }),
          described_class.new('foo', Class.new { def self.call ; nil ; end }),
          described_class.new('foo', Class.new { def self.call ; raise ; end }),
        ]
      end

      it 'returns an error' do
        subjects.each do |subject|
          expect(subject.call).to be_a(HealthBit::CheckError)
        end
      end
    end

    context 'when success' do
      let(:subjects) do
        [
          described_class.new('bar', -> { true }),
          described_class.new('bar', Class.new { def self.call ; true ; end }),
        ]
      end

      it 'returns an error' do
        subjects.each do |subject|
          expect(subject.call).to eq(nil)
        end
      end
    end
  end
end
