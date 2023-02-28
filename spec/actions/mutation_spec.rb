# frozen_string_literal: true

RSpec.describe 'actions/mutation', :vcr do

  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { JSON.parse(File.read('fixtures/actions/mutation/input/person_update.json')) }
  let(:expected_output) { JSON.parse(File.read('fixtures/actions/mutation/output/person_update.json')) }

  subject(:output) { connector.actions.mutation(input) }

  # This spec only works on staging because of the user ID in 'fixtures/actions/mutation/input/person_update.json'.

  describe 'test mutation' do
    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains clientMutationId, person and errors' do
      expect(output).to include('clientMutationId')
      expect(output).to include('person')
      expect(output).to include('errors')
    end

    it 'gives expected output' do
      expect(output).to eq(expected_output)
    end
    
  end
end
