RSpec.describe HealthBit::Check do
  describe '#call' do
    context 'when fail' do
      let(:subjects) do
        [
          described_class.new('foo', -> { nil }),
          described_class.new('foo', -> { false }),
          described_class.new('foo', -> { raise }),
          described_class.new('foo', -> { break(false); true }),
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
          described_class.new('bar', -> { break(true); false }),
          described_class.new('bar', Class.new { def self.call ; true ; end }),
        ]
      end

      it 'returns an error' do
        subjects.each do |subject|
          expect(subject.call).to eq(nil)
        end
      end
    end

    context 'env' do
      let(:subjects) do
        [
          described_class.new('foo', -> (env) { env.call }),
          described_class.new('foo', Class.new { def self.call(env) ; env.call ; end }),
          described_class.new('foo', Proc.new { |env| env.call  }),
        ]
      end


      it 'passes env to a handler' do
        subjects.each do |subject|
          env = double('student')
          expect(env).to receive(:call).once
          subject.call(env)
        end
      end
    end
  end
end
