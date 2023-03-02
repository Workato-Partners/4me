# frozen_string_literal: true

RSpec.describe 'object_definition/common_with_localized_name', :vcr do
  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.common_with_localized_name }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { {} }

    it 'returns schema definition' do
      expect(schema_fields).to eq(
        [
          { 'name' => 'id', 'type' => 'integer' },
          { 'name' => 'nodeID' },
          { 'name' => 'name' },
          { 'name' => 'localized_name' },
          { 'name' => 'account', 'type' => 'object', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }] }
        ]
      )
    end
  end
end
