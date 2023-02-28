# frozen_string_literal: true

RSpec.describe 'object_definition/account', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.account }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { {} }

    it 'returns schema definition' do
      expect(schema_fields).to eq([
        { 'name' => 'id' },
        { 'name' => 'name' },
      ])
    end
  end

end
