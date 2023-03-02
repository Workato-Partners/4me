# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

RSpec.describe 'methods/get_operation_fields', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'get query operation fields' do
    let(:result) { connector.methods.get_operation_fields(settings, nil, 'query') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains account, agileBoards, workflows and contracts' do
      expect(result.any? { |hash| hash['name'] == 'account' }).to be_truthy
      expect(result.any? { |hash| hash['name'] == 'agileBoards' }).to be_truthy
      expect(result.any? { |hash| hash['name'] == 'workflows' }).to be_truthy
      expect(result.any? { |hash| hash['name'] == 'contracts' }).to be_truthy
    end

    it 'not contains agileBoardUpdate and workflowUpdate' do
      expect(result.any? { |hash| hash['name'] == 'agileBoardUpdate' }).to be_falsey
      expect(result.any? { |hash| hash['name'] == 'workflowUpdate' }).to be_falsey
    end
  end

  describe 'get mutation operation fields' do
    let(:result) { connector.methods.get_operation_fields(settings, nil, 'mutation') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains agileBoardUpdate, noteCreate and workflowUpdate' do
      expect(result.any? { |hash| hash['name'] == 'agileBoardUpdate' }).to be_truthy
      expect(result.any? { |hash| hash['name'] == 'noteCreate' }).to be_truthy
      expect(result.any? { |hash| hash['name'] == 'workflowUpdate' }).to be_truthy
    end

    it 'not contains account and contracts' do
      expect(result.any? { |hash| hash['name'] == 'account' }).to be_falsey
      expect(result.any? { |hash| hash['name'] == 'contracts' }).to be_falsey
    end
  end
end

# rubocop:enable Metrics/BlockLength
