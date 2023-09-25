# frozen_string_literal: true

RSpec.describe 'actions/query', :vcr do # rubocop:disable Metrics/BlockLength
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'Query people with configuration items' do
    let(:input) { JSON.parse(File.read('fixtures/actions/query/input/people_with_cis.json')) }
    subject(:output) { connector.actions.query(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains nodes and totalCount' do
      expect(output).to include('nodes')
      expect(output).to include('totalCount')
    end

    it 'contains rate limit information' do
      expect(output).to include('rate_limit_headers')
      expect(output['rate_limit_headers']).to include('limit')
      expect(output['rate_limit_headers']).to include('remaining')
      expect(output['rate_limit_headers']).to include('reset')
    end

    it 'contains totalCount greater than 0' do
      expect(output[:totalCount]).to be_positive
    end

    it 'contains configurationItems with identifier' do
      expect(output[:nodes].first).to include(:configurationItems, :id)
    end
  end

  describe 'Query services with service instance, SLA and offerings' do
    let(:input) { JSON.parse(File.read('fixtures/actions/query/input/services.json')) }
    subject(:output) { connector.actions.query(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains nodes and totalCount' do
      expect(output).to include('nodes')
      expect(output).to include('totalCount')
    end

    it 'contains totalCount greater than 0' do
      expect(output[:totalCount]).to be_positive
    end

    it 'contains connections with identifier' do
      expect(output[:nodes].first).to include(:serviceInstances, :id)
      expect(output[:nodes].first).to include(:serviceLevelAgreements, :id)
      expect(output[:nodes].first).to include(:serviceOfferings, :id)
    end
  end
end
