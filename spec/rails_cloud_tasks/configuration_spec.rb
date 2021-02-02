# rubocop:disable Metrics/BlockLength
describe RailsCloudTasks::Configuration do
  subject(:configuration) { described_class.new(app_engine, google_auth) }

  let(:app_engine) { class_spy(RailsCloudTasks::AppEngine) }
  let(:google_auth) { class_spy(Google::Auth) }

  describe '#new' do
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

  describe '#auth' do
    subject(:call_auth) { configuration.auth }

    let(:expected_auth) do
      {
        oidc_token: {
          service_account_email: service_account_email
        }
      }
    end

    context 'when service account email is set on class init' do
      let(:service_account_email) { 'email-test@iam.google' }

      before do
        stub_const('ENV', ENV.to_hash.merge('GCP_SERVICE_ACCOUNT' => service_account_email))
      end

      it { is_expected.to eql(expected_auth) }

      it do
        call_auth
        expect(app_engine).not_to have_received(:service_account_email)
      end

      it do
        call_auth
        expect(google_auth).not_to have_received(:get_application_default)
      end
    end

    context 'when service account email get from app engine' do
      let(:service_account_email) { 'engine-email-test@iam.google' }

      before do
        allow(app_engine).to receive(:service_account_email).and_return(service_account_email)
      end

      it { is_expected.to eql(expected_auth) }

      it do
        call_auth
        expect(app_engine).to have_received(:service_account_email)
      end

      it do
        call_auth
        expect(google_auth).not_to have_received(:get_application_default)
      end
    end

    context 'when service account email get from google auth' do
      let(:service_account_email) { 'google-auth-email-test@iam.google' }
      let(:metadata) { OpenStruct.new(issuer: service_account_email) }

      before do
        allow(app_engine).to receive(:service_account_email).and_return(nil)
        allow(google_auth).to receive(:get_application_default).and_return(metadata)
      end

      it { is_expected.to eql(expected_auth) }

      it do
        call_auth
        expect(app_engine).to have_received(:service_account_email)
      end

      it do
        call_auth
        expect(google_auth).to have_received(:get_application_default)
      end
    end
  end

  describe '#project_id' do
    subject(:call_project_id) { configuration.project_id }

    context 'when the project_id is set' do
      let(:project_id) { 'conf-test' }

      before do
        configuration.project_id = project_id
      end

      it { is_expected.to eq(project_id) }

      it do
        call_project_id
        expect(app_engine).not_to have_received(:project_id)
      end
    end

    context 'when the project_id get from app_engine set' do
      let(:project_id) { 'app-engine-conf-test' }

      before do
        allow(app_engine).to receive(:project_id).and_return(project_id)
      end

      it { is_expected.to eq(project_id) }

      it do
        call_project_id
        expect(app_engine).to have_received(:project_id)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
