require 'active_support/core_ext'
require 'google/cloud/tasks/v2'

describe RailsCloudTasks::AppEngine do
  subject(:app_engine) { described_class }

  describe 'project_id' do
    subject(:project_id) { app_engine.project_id }

    before { app_engine.reset! }

    context 'when not on GCE' do
      before do
        allow(::Google::Auth::GCECredentials).to receive(:on_gce?).and_return(false)
      end

      it { is_expected.to be_nil }
    end

    context 'when on GCE' do
      let(:project) { 'test-project' }

      before do
        allow(::Google::Auth::GCECredentials).to receive(:on_gce?).and_return(true)
        stub_request(:get, %r{http://metadata.google.internal}).and_return(body: project)
      end

      it { is_expected.to eq project }
    end
  end

  describe 'service_account_email' do
    subject(:service_account_email) { app_engine.service_account_email }

    before { app_engine.reset! }

    context 'when not on GCE' do
      before do
        allow(::Google::Auth::GCECredentials).to receive(:on_gce?).and_return(false)
      end

      it { is_expected.to be_nil }
    end

    context 'when on GCE' do
      let(:email) { 'test-account@test-project.iam.gserviceaccount.com' }

      before do
        allow(::Google::Auth::GCECredentials).to receive(:on_gce?).and_return(true)
        stub_request(:get, %r{http://metadata.google.internal}).and_return(body: email)
      end

      it { is_expected.to eq email }
    end
  end
end
