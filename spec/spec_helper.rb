# frozen_string_literal: true

require 'webmock/rspec'
require 'timecop'
require 'vcr'
require 'workato-connector-sdk'
require 'workato/testing/vcr_encrypted_cassette_serializer'
require 'workato/testing/vcr_multipart_body_matcher'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'tape_library'
  config.hook_into :webmock
  # config.debug_logger = File.open('tape_library.log', 'w')
  config.cassette_serializers[:encrypted] = Workato::Testing::VCREncryptedCassetteSerializer.new

  config.register_request_matcher :headers_without_user_agent do |request1, request2|
    request1.headers.except('User-Agent') == request2.headers.except('User-Agent')
  end

  config.register_request_matcher :multipart_body do |request1, request2|
    Workato::Testing::VCRMultipartBodyMatcher.call(request1, request2)
  end

  config.register_request_matcher :custom_matcher do |request1, request2|
    if request1.uri.include?('https://graphql.') && request1.uri == request2.uri
      request1.method == request2.method &&
        request1.body == request2.body &&
        request1.headers.except('User-Agent') == request2.headers.except('User-Agent')
    else
      request1.uri == request2.uri
    end
  end

  config.default_cassette_options = {
    record: ENV.fetch('VCR_RECORD_MODE', :none).to_sym,
    decode_compressed_response: false,
    serialize_with: :encrypted,
    # match_requests_on: %i[uri headers_without_user_agent body]
    match_requests_on: %i[uri custom_matcher]
  }
  config.configure_rspec_metadata!
end
