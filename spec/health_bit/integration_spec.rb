RSpec.describe HealthBit do
  let(:app1) do
    described_class.clone
  end

  let(:app2) do
    described_class.clone
  end

  let(:app3) do
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

  before do
    app3.headers = { 'app3' => 1 }
    app3.success_code = 200
    app3.fail_code = 500
    app3.add('app3') do |env|
      env["FOO"] == "BAR"
    end
  end

  context 'when app1' do
    it 'passes' do
      status, headers, content = app1.rack.call({})

      expect(status).to eq(201)
      expect(headers).to eq('app1' => 1)
      expect(content).to contain_exactly('1 checks passed 🎉')
    end
  end

  context 'when app2' do
    it 'passes' do
      status, headers, content = app2.rack.call({})

      expect(status).to eq(503)
      expect(headers).to eq('app2' => 2)
      expect(content).to contain_exactly("Check <app2> failed")
    end
  end

  context 'when app3' do
    it 'passes' do
      status, headers, content = app3.rack.call({ 'FOO' => 'BAR' })

      expect(status).to eq(200)
      expect(headers).to eq('app3' => 1)
      expect(content).to contain_exactly('1 checks passed 🎉')
    end
  end
end
