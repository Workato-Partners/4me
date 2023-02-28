# frozen_string_literal: true

RSpec.describe 'methods/build_action_output_fields', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.build_action_output_fields(arg_1, arg_2) }

  pending 'add some examples'
end
