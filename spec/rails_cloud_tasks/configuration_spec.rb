describe RailsCloudTasks::Configuration do
  subject(:configuration) { described_class }

  describe '#new' do
    subject(:configuration_new) { configuration.new(app_engine) }

    let(:app_engine) { class_spy(RailsCloudTasks::AppEngine) }
    let(:service_account_email) { 'email@sample.com' }

    its(:service_account_email) { is_expected.to be_nil }
    its(:location_id) { is_expected.to be_nil }
    its(:tasks_path) { is_expected.to eql('/tasks') }

    context 'when config is set by ENVs' do
      let(:stubs) do
        {
          'GCP_LOCATION' => 'env-location',
          'GCP_SERVICE_ACCOUNT' => 'env-email@sample.com',
          'GCP_PROJECT' => 'env-project-test'
        }
      end

      before do
        stub_const('ENV', ENV.to_hash.merge(stubs))
      end

      its(:location_id) { is_expected.to eql(stubs['GCP_LOCATION']) }
      its(:project_id) { is_expected.to eql(stubs['GCP_PROJECT']) }
      its(:service_account_email) { is_expected.to eql(stubs['GCP_SERVICE_ACCOUNT']) }
    end
  end
end
