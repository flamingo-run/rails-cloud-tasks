require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::Rack::Tasks do
  let(:env) do
    { 'rack.input' => StringIO.new(payload) }
  end

  let(:payload) do
    {
      job: {
        job_class:       'DummyJob',
        job_id:          'a0af08ef-c4b2-4f80-aba8-ce28ffbf910f',
        provider_job_id: nil,
        queue_name:      'test-queue',
        priority:        nil,
        arguments:       [123],
        executions:      0,
        locale:          'en'
      }
    }.to_json
  end

  describe 'call' do
    subject(:call) { described_class.call(env) }

    before do
      allow(ActiveJob::Base).to receive(:execute).and_return(:ok)
    end

    context 'when job is successfully attempted' do
      its(:first)  { is_expected.to eq 200 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{ error: nil }.to_json] }
    end

    context 'when payload is incorrect' do
      let(:payload) { {}.to_json }

      its(:first)  { is_expected.to eq 400 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{ error: 'key not found: "job"' }.to_json] }
    end

    context 'when execution fails' do
      before do
        allow(ActiveJob::Base).to receive(:execute).and_raise(StandardError, 'some error')
      end

      its(:first)  { is_expected.to eq 500 }
      its(:second) { is_expected.to eq('Content-Type' => 'application/json') }
      its(:third)  { is_expected.to eq [{ error: 'some error' }.to_json] }
    end
  end
end
