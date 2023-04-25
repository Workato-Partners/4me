# frozen_string_literal: true

RSpec.describe 'methods/get_schema', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.get_schema(settings) }

  describe 'get schema' do
    it 'contains a response' do
      expect(result).to be_present
    end

    it 'contains __schema and types' do
      expect(result).to include('__schema')
      expect(result[:__schema]).to include('types')
    end
  end
end
