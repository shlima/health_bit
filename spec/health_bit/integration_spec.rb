RSpec.describe HealthBit do
  let(:app1) do
    described_class.clone
  end

  let(:app2) do
    described_class.clone
  end

  before do
    # just initialize instance variable
    # inside a donor
    described_class.checks
  end

  before do
    app1.headers = { 'app1' => 1 }
    app1.success_code = 201
    app1.fail_code = 0
    app1.add('app1') do
      true
    end
  end

  before do
    app2.headers = { 'app2' => 2 }
    app2.success_code = 0
    app2.fail_code = 503
    app2.add('app2') do
      false
    end
  end

  context 'when app1' do
    it 'passed' do
      status, headers, content = app1.rack.call({})

      expect(status).to eq(201)
      expect(headers).to eq('app1' => 1)
      expect(content).to contain_exactly('1 checks passed 🎉')
    end
  end

  context 'when app2' do
    it 'passed' do
      status, headers, content = app2.rack.call({})

      expect(status).to eq(503)
      expect(headers).to eq('app2' => 2)
      expect(content).to contain_exactly("Check <app2> failed")
    end
  end
end
