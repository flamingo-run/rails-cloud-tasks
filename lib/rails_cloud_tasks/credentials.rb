module RailsCloudTasks
  class Credentials
    require 'googleauth'
    require 'google/apis/iamcredentials_v1'

    DEFAULT_SCOPES = ['https://www.googleapis.com/auth/cloud-platform'].freeze
    attr_reader :request_options, :iam_credential, :token_request, :auth

    def initialize(
      request_options: Google::Apis::RequestOptions.new,
      iam_credential: Google::Apis::IamcredentialsV1::IAMCredentialsService.new,
      token_request: Google::Apis::IamcredentialsV1::GenerateAccessTokenRequest,
      auth: Google::Auth
    )
      @auth = auth
      @request_options = request_options
      @iam_credential = iam_credential
      @token_request = token_request
    end

    def generate(impersonate_account = nil, scopes = [])
      current_scopes = DEFAULT_SCOPES + scopes
      authorization = auth.get_application_default(current_scopes).dup
      request_options.authorization = authorization

      if impersonate_account
        iam_credential.generate_service_account_access_token(
          "projects/-/serviceAccounts/#{impersonate_account}",
          token_request.new(scope: current_scopes, lifetime: '3600s'),
          options: request_options
        )
      end

      request_options.authorization
    end
  end
end
