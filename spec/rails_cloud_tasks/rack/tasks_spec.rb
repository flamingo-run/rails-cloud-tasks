require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::Rack::Tasks do
  let(:env) do
    { 'rack.input' => StringIO.new(payload.to_json) }
  end

  let(:arguments) { [123] }

  let(:payload) do
    {
      job: {
        job_class:       'DummyJob',
        job_id:          'a0af08ef-c4b2-4f80-aba8-ce28ffbf910f',
        provider_job_id: nil,
        queue_name:      'test-queue',
        priority:        nil,
        arguments:       arguments,
        executions:      0,
        locale:          'en'
      }
    }
  end

  describe 'call' do
    subject(:call) { described_class.call(env) }

    before do
      allow(ActiveJob::Base).to receive(:execute).and_return(:ok)
      allow(RailsCloudTasks::Instrumentation).to receive(:transaction_name!)
      allow(RailsCloudTasks::Instrumentation).to receive(:add_custom_attributes)
    end

    it do
      call
      expect(RailsCloudTasks::Instrumentation).to have_received(:transaction_name!)
        .with("RailsCloudTasks/#{payload[:job][:job_class]}/perform_now")
    end

    it do
      call
      expect(RailsCloudTasks::Instrumentation).to have_received(:add_custom_attributes)
        .with({ request_body: arguments })
    end

    context 'when job is successfully attempted' do
      its(:first)  { is_expected.to eq 200 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{}.to_json] }
    end

    context 'when payload is incorrect' do
      let(:payload) { {} }

      its(:first)  { is_expected.to eq 400 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{ error: 'key not found: "job"' }.to_json] }
    end

    context 'when execution fails' do
      before do
        allow(ActiveJob::Base).to receive(:execute).and_raise(StandardError, 'some error')
      end

      it do
        expect { call }.to raise_error(StandardError)
      end
    end
  end
end
