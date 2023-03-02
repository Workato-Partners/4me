# frozen_string_literal: true

RSpec.describe 'methods/run_gql', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'run me query' do
    let(:result) { connector.methods.run_gql(settings, '{ me { id name } }', '', 'wdc') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains a me' do
      expect(result).to include('me')
      expect(result[:me]).to include('id', 'name')
    end
  end
end
