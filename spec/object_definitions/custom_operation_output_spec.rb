# frozen_string_literal: true

RSpec.describe 'object_definition/custom_operation_output', :vcr do
  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.custom_operation_output }

  describe 'custom operations output' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { 'query' => 'query { me { id } }' } }

    it 'contains output' do
      expect(output).to be_present
    end

    it 'includes me and ID label' do
      expect(schema_fields.first).to include('label' => 'Rate limit')
      expect(schema_fields.last).to include('label' => 'Me')
      expect(schema_fields.last[:properties].first).to include('label' => 'ID', 'name' => 'id')
    end
  end
end
