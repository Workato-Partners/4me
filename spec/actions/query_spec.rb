# frozen_string_literal: true

RSpec.describe 'actions/query', :vcr do
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { JSON.parse(File.read('fixtures/actions/query/input/people_with_cis.json')) }

  subject(:output) { connector.actions.query(input) }

  describe 'test query' do
    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains nodes and totalCount' do
      expect(output).to include('nodes')
      expect(output).to include('totalCount')
    end

    it 'contains totalCount greater than 0' do
      # rubocop:disable Style/NumericPredicate
      expect(output[:totalCount]).to be > 0
      # rubocop:enable Style/NumericPredicate
    end

    it 'contains id and configurationItems' do
      expect(output[:nodes].first).to include(:configurationItems, :id)
    end
  end
end
