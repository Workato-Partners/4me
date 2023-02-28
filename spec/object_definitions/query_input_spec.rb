# frozen_string_literal: true

RSpec.describe 'object_definition/query_input', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.query_input }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }

    pending 'add some examples'
    pending 'output is a stream'
  end
end
