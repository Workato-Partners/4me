# frozen_string_literal: true

RSpec.describe 'object_definition/mutation_input', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.mutation_input }

  describe 'mutation input' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { } }

    it 'account' do
      expect(schema_fields.first).to include('control_type' => 'text')
      expect(schema_fields.first).to include('default')
      expect(schema_fields.first).to include('label' => 'Account ID')
      expect(schema_fields.first).to include('name' => 'account')
    end

    it 'mutation' do
      expect(schema_fields.last).to include('label' => 'Mutation')
      expect(schema_fields.last).to include('name' => 'object')
      expect(schema_fields.last).to include('extends_schema' => true)
      expect(schema_fields.last).to include('optional' => false)
      expect(schema_fields.last[:pick_list]).to_not be_empty
    end
  end
end
