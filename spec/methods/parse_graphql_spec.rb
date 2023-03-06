# frozen_string_literal: true

RSpec.describe 'methods/parse_graphql', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'parse me query' do
    let(:result) { connector.methods.parse_graphql(nil, '{ me { id name } }') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains documents and fragments' do
      expect(result[:documents]).to be_present
      expect(result[:fragments]).to eq([])
    end
  end
end
