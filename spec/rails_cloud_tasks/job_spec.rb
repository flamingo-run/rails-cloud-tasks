require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::Job do
  let(:dummy_class) { Class.new { include RailsCloudTasks::Job } }
  let(:instance) { instance_spy(dummy_class) }

  describe 'perform_now' do
    before do
      allow(dummy_class).to receive(:new).and_return(instance)

      dummy_class.perform_now
    end

    it 'executes the job immediatelly' do
      expect(instance).to have_received(:perform)
    end
  end

  describe 'perform_later' do
    subject(:perform_later) { dummy_class.perform_later }

    before do
      allow(dummy_class).to receive(:enqueue_task).with(nil).and_return('task-id')
    end

    it { is_expected.to eq 'task-id' }
  end

  describe 'perform_in' do
    subject(:perform_in) { dummy_class.perform_in(1.minute) }

    before do
      allow(dummy_class).to receive(:enqueue_task)
        .with(nil, instance_of(Integer))
        .and_return('task-id')
    end

    it { is_expected.to eq 'task-id' }
  end

  describe 'perform_at' do
    subject(:perform_at) { dummy_class.perform_at(1.hour.from_now) }

    before do
      allow(dummy_class).to receive(:enqueue_task)
        .with(nil, instance_of(Integer))
        .and_return('task-id')
    end

    it { is_expected.to eq 'task-id' }
  end

  describe 'queue management' do
    subject(:enqueue_task) { dummy_class.perform_in(3.minutes) }

    let(:client) { instance_spy(Google::Cloud::Tasks::V2::CloudTasks::Client) }
    let(:queue_path) { 'projetcs/project_id/location/location_id/queues/queue_id' }

    before do
      allow(dummy_class).to receive(:client).and_return(client)
      allow(client).to receive(:queue_path).and_return(queue_path)
    end

    context 'when the queue does not exist' do
      before do
        first_call = true

        allow(client).to receive(:create_task) do
          if first_call
            first_call = false
            raise Google::Cloud::FailedPreconditionError
          end
          OpenStruct.new(name: 'task-id')
        end

        enqueue_task
      end

      it 'creates the queue' do
        expect(client).to have_received(:create_queue)
      end
    end

    describe 'queue_attrs' do
      subject(:queue_attrs) { dummy_class.queue_attrs }

      context 'with default settings' do
        it do
          is_expected.to eq(
            project:  'test-project',
            location: 'us-central1',
            queue:    'test-queue'
          )
        end
      end

      context 'with per job settings' do
        before do
          dummy_class.project_id('per-job-project')
          dummy_class.location_id('per-job-location')
          dummy_class.queue_id('per-job-queue')
        end

        it do
          is_expected.to eq(
            project:  'per-job-project',
            location: 'per-job-location',
            queue:    'per-job-queue'
          )
        end
      end
    end
  end
end
