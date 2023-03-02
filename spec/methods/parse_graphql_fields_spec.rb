# frozen_string_literal: true

RSpec.describe 'methods/parse_graphql_fields', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'parse me query fields' do
    let(:result) { connector.methods.parse_graphql_fields(settings, nil, '{ me { id name } }') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains name and fields' do
      expect(result.first[:name]).to eq('me')
      expect(result.first[:fields]).to eq([{ 'name' => 'id' }, { 'name' => 'name' }])
    end
  end
end
