require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::Adapter do
  subject(:instance) { described_class.new(client) }

  let(:job) { DummyJob.new(args) }
  let(:args) { { arg1: 'one', arg2: 'two', text: 'By forcing encode âã' } }
  let(:tomorrow) { (Time.now + 1.day).to_i }
  let(:config) { RailsCloudTasks.config }

  let(:client) { instance_spy(Google::Cloud::Tasks::V2::CloudTasks::Client) }

  describe 'enqueue' do
    subject(:enqueue) { instance.enqueue(job, tomorrow) }

    let(:queue_path) { '/this/valid/path' }
    let(:expected_task) do
      {
        http_request: hash_including(
          body: { job: job.serialize }.to_json.force_encoding('ASCII-8BIT')
        )
      }
    end

    context 'when the queue exists' do
      before do
        allow(client).to receive(:create_task).and_return('task-id')
        allow(client).to receive(:queue_path).and_return(queue_path)
      end

      it { is_expected.to eq 'task-id' }

      it do
        enqueue
        expect(client).to have_received(:queue_path).with(
          project: config.project_id, location: config.location_id,
          queue: job.queue_name
        )
      end

      it do
        enqueue
        expect(client).to have_received(:create_task).with(parent: queue_path,
                                                           task:   hash_including(expected_task))
      end
    end

    context 'when the queue does exist' do
      let(:exception) { Google::Cloud::FailedPreconditionError.new }

      before do
        first_call = true

        allow(exception).to receive(:details).and_return('Queue does not exist.')

        allow(client).to receive(:queue_path).and_return('project/test-project/queues/test-queue')
        allow(client).to receive(:create_queue).and_return({})
        allow(client).to receive(:create_task) do
          if first_call
            first_call = false

            raise exception
          end
          OpenStruct.new(name: 'task-id')
        end
      end

      it 'creates the queue' do
        enqueue
        expect(client).to have_received(:create_queue).once
      end

      its(:name) { is_expected.to eq 'task-id' }
    end
  end

  describe 'enqueue_at' do
    subject(:enqueue_at) { instance.enqueue_at(job, tomorrow) }

    before do
      allow(instance).to receive(:enqueue).and_return(OpenStruct.new(name: 'task-id'))
    end

    it 'calls enqueue with the timestamp' do
      enqueue_at
      expect(instance).to have_received(:enqueue).with(job, tomorrow)
    end

    its(:name) { is_expected.to eq 'task-id' }
  end
end
