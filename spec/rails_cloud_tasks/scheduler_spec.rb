describe RailsCloudTasks::Scheduler do
  require 'google/cloud/scheduler/v1'
  subject(:scheduler) { described_class.new(client: client, credentials: credentials) }

  let(:client) { instance_spy(Google::Cloud::Scheduler::V1::CloudScheduler::Client) }
  let(:credentials) { instance_spy(RailsCloudTasks::Credentials) }
  let(:config) { RailsCloudTasks.config }
  let(:service_account_email) { config.service_account_email }

  context 'with credentials' do
    let(:configuration) do
      instance_spy(Google::Cloud::Scheduler::V1::CloudScheduler::Client::Configuration)
    end
    let(:fake_credential) { 'fake generated credential' }

    before do
      allow(client).to receive(:configure).and_yield(configuration)
      allow(credentials).to receive(:generate).and_return(fake_credential)
    end

    it do
      scheduler
      expect(credentials).to have_received(:generate).with(service_account_email)
    end

    it do
      scheduler
      expect(configuration).to have_received(:credentials=).with(fake_credential)
    end
  end

  describe '#upsert' do
    subject(:upsert) { scheduler.upsert }

    let(:location_path) { 'location/path/to/schedule' }
    let(:project) { config.project_id }
    let(:location) { config.location_id }
    let(:tasks_path) { config.tasks_path }
    let(:host) { config.host }

    let(:job1) do
      {
        name:        "#{location_path}/jobs/testing-rails-cloud__HashArgsJob",
        schedule:    '0 8 * * *',
        description: 'Hash args',
        time_zone:   'America/Los_Angeles',
        http_target: {
          uri:         "#{host}#{tasks_path}/HashArgsJob",
          http_method: 'POST',
          body:        '{"arg1":100,"arg2":200}',
          oidc_token:  {
            service_account_email: service_account_email
          }
        }
      }
    end
    let(:job2) do
      {
        name:        "#{location_path}/jobs/testing-rails-cloud__MultArgsJob",
        schedule:    '0 8 * * *',
        description: 'Mult args',
        time_zone:   'America/Los_Angeles',
        http_target: {
          uri:         "#{host}#{tasks_path}/MultArgsJob",
          http_method: 'POST',
          body:        '[{"arg1":100,"arg2":200},{"arg1":3}]',
          oidc_token:  {
            service_account_email: service_account_email
          }
        }
      }
    end

    before do
      allow(client).to receive(:location_path).and_return(location_path)
    end

    it do
      upsert
      expect(client).to have_received(:location_path).with(project: project, location: location)
    end

    context 'when the scheduled jobs does not exists' do
      it do
        upsert
        expect(client).to have_received(:create_job)
          .with(parent: location_path, job: job1)
          .with(parent: location_path, job: job2)
      end
    end

    context 'when any job already exists' do
      before do
        # Before stub something with value - `with` command - a stub default value must be defined
        allow(client).to receive(:create_job)
        allow(client).to receive(:create_job).with(parent: location_path,
                                                   job:    job2)
                                             .and_raise(Google::Cloud::AlreadyExistsError)
      end

      it do
        upsert
        expect(client).to have_received(:create_job)
          .with(parent: location_path, job: job1)
          .with(parent: location_path, job: job2)
      end

      it do
        upsert
        expect(client).not_to have_received(:update_job).with(job: job1)
      end

      it do
        upsert
        expect(client).to have_received(:update_job).with(job: job2)
      end
    end
  end
end
