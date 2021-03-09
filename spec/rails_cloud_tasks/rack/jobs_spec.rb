require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::Rack::Jobs do
  let(:env) do
    {
      'action_dispatch.request.path_parameters' => { job_class: job_class },
      'rack.input' => StringIO.new(payload)
    }
  end

  let(:job_class) { 'DummyJob' }
  let(:payload) { args.to_json }
  let(:args) { [{ arg1: 'one', arg2: 'two' }.stringify_keys, 'params 2'] }

  describe 'call' do
    subject(:call) { described_class.call(env) }

    before do
      allow(DummyJob).to receive(:perform_now).with(*args).and_return(:ok)
      allow(RailsCloudTasks::Instrumentation).to receive(:transaction_name!)
    end

    it do
      call
      expect(RailsCloudTasks::Instrumentation).to have_received(:transaction_name!)
        .with("RailsCloudTasks/#{job_class}/perform_now")
    end

    context 'when job is successfully attempted' do
      its(:first)  { is_expected.to eq 200 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{}.to_json] }
    end

    context 'when payload is invalid' do
      let(:payload) { 'wubba-lubba-dub-dub' }

      its(:first)  { is_expected.to eq 422 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }

      its(:third)  do
        is_expected.to eq [{ error: 'RailsCloudTasks::Rack::InvalidPayloadError' }.to_json]
      end
    end

    context 'when execution fails' do
      before do
        allow(DummyJob).to receive(:perform_now).and_raise(StandardError, 'some error')
      end

      its(:first)  { is_expected.to eq 500 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{ error: 'some error' }.to_json] }
    end
  end
end
