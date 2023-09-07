# frozen_string_literal: true

RSpec.describe 'actions/mutation', :vcr do # rubocop:disable Metrics/BlockLength
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # This spec only works on staging because of the user ID in 'fixtures/actions/mutation/input/person_update.json'.

  describe 'test person create mutation' do
    let(:input) { JSON.parse(File.read('fixtures/actions/mutation/input/person_update.json')) }
    let(:expected_output) { JSON.parse(File.read('fixtures/actions/mutation/output/person_update.json')) }
    subject(:output) { connector.actions.mutation(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'gives expected output' do
      expect(output).to include('clientMutationId')
      expect(output).to include('person')
      expect(output).to include('errors')
      expect(output).to include('rate_limit_headers')
      expect(output['rate_limit_headers']).to include('limit')
      expect(output['rate_limit_headers']).to include('remaining')
      expect(output['rate_limit_headers']).to include('reset')
      expect(output['clientMutationId']).to eq('rspec')
      expect(output['person']['timeFormat24h']).to eq(true)
    end
  end

  describe 'test request create mutation with error' do
    let(:input) { JSON.parse(File.read('fixtures/actions/mutation/input/request_create_with_error.json')) }
    subject(:output) { connector.actions.mutation(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains errors' do
      expect(output).to include('errors')
      expect(output[:errors].count).to be_positive
    end
  end
end
