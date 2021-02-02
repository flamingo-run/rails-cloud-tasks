describe RailsCloudTasks::Credentials do
  subject(:credentials) do
    described_class.new(
      request_options: request_options,
      iam_credential:  iam_credential,
      token_request:   token_request,
      auth:            auth
    )
  end

  let(:request_options) { Google::Apis::RequestOptions.new }
  let(:iam_credential) { instance_spy(Google::Apis::IamcredentialsV1::IAMCredentialsService) }
  let(:token_request) { class_spy(Google::Apis::IamcredentialsV1::GenerateAccessTokenRequest) }
  let(:auth) { class_spy(Google::Auth) }

  it do
    expect(described_class::DEFAULT_SCOPES).to eql(
      ['https://www.googleapis.com/auth/cloud-platform']
    )
  end

  describe '#generate' do
    subject(:generate) { credentials.generate(impersonate_account, scopes) }

    let(:scopes) { ['https://another.scope'] }
    let(:default_authorization) { 'default_authorization' }
    let(:all_scopes) { described_class::DEFAULT_SCOPES + scopes }

    before do
      allow(auth).to receive(:get_application_default).and_return(default_authorization)
    end

    context 'when impersonate account is not provided' do
      let(:impersonate_account) { nil }

      it { is_expected.to eql(default_authorization) }

      it do
        generate
        expect(auth).to have_received(:get_application_default).with(all_scopes)
      end

      it do
        generate
        expect(iam_credential).not_to have_received(:generate_service_account_access_token)
      end
    end

    context 'when impersonate account is provided' do
      let(:impersonate_account) { 'impersonate@account.com' }
      let(:impersonate_token) { 'fake impersonate token' }

      before do
        allow(iam_credential).to receive(:generate_service_account_access_token) do
          request_options.authorization = impersonate_token
        end
      end

      it { is_expected.to eql(impersonate_token) }

      it do
        generate
        expect(auth).to have_received(:get_application_default).with(all_scopes)
      end

      it do
        generate
        expect(iam_credential).to have_received(:generate_service_account_access_token).with(
          "projects/-/serviceAccounts/#{impersonate_account}",
          token_request.new(scope: all_scopes, lifetime: '3600s'), options: request_options
        )
      end
    end
  end
end
