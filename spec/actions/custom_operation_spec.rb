# frozen_string_literal: true

RSpec.describe 'actions/custom_operation', :vcr do # rubocop:disable Metrics/BlockLength
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'test custom operation with single query' do
    let(:input) { JSON.parse(File.read('fixtures/actions/custom_operation/input/query.json')) }
    subject(:output) { connector.actions.custom_operation(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains people' do
      expect(output).to include('people')
      expect(output[:people]).to_not be_empty
    end

    it 'contains id account and configurationItems' do
      expect(output[:people][:nodes].first).to include('id', 'configurationItems', 'account')
    end
  end

  describe 'test custom operation with multiple queries' do
    let(:input) { JSON.parse(File.read('fixtures/actions/custom_operation/input/query_operation_name.json')) }
    subject(:output) { connector.actions.custom_operation(input) }

    it 'contains a response' do
      expect(output).to be_present
    end

    it 'contains id, name and primary email' do
      expect(output[:node]).to include('id', 'name', 'primaryEmail')
      expect(output[:node][:primaryEmail]).to eq('aleksei.zelensk@microsoft.com')
    end
  end

  describe 'test custom operation with multiple queries but no operation selected' do
    let(:input) { JSON.parse(File.read('fixtures/actions/custom_operation/input/query_operation_name_error.json')) }
    subject(:output) { connector.actions.custom_operation(input) }

    it 'contains an MissingRequiredInput error' do
      expect { output }.to raise_error(Workato::Connector::Sdk::MissingRequiredInput)
    end
  end
end
