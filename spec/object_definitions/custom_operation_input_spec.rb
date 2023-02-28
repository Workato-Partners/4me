# frozen_string_literal: true

RSpec.describe 'object_definition/custom_operation_input', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.custom_operation_input }

  describe 'custom operations input fields' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { } }

    it 'account' do
      expect(schema_fields.first).to include('control_type' => 'text')
      expect(schema_fields.first).to include('default')
      expect(schema_fields.first).to include('label' => 'Account ID')
      expect(schema_fields.first).to include('name' => 'account')
    end

    it 'query' do
      expect(schema_fields.last).to include('label' => 'Query')
      expect(schema_fields.last).to include('name' => 'query')
      expect(schema_fields.last).to include('extends_schema' => true)
    end
  end
end
