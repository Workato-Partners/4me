# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

RSpec.describe 'methods/get_operation_type', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'get query operation' do
    let(:result) { connector.methods.get_operation_type(settings, 'query') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains fields' do
      expect(result).to include('fields')
    end

    it 'fields contains account, configurationitems and people' do
      expect(result[:fields].any? { |hash| hash['name'] == 'account' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'configurationItems' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'people' }).to be_truthy
    end
  end

  describe 'get mutation operation' do
    let(:result) { connector.methods.get_operation_type(settings, 'mutation') }

    it 'contains a result' do
      expect(result).to be_present
    end

    it 'contains fields' do
      expect(result).to include('fields')
    end

    it 'fields contains personCreate, personUpdate, configurationItemCreate and webhookCreate' do
      expect(result[:fields].any? { |hash| hash['name'] == 'personCreate' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'personUpdate' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'configurationItemCreate' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'webhookCreate' }).to be_truthy
    end
  end

  describe 'get non-existing operation' do
    let(:result) { connector.methods.get_operation_type(settings, 'non-existing') }

    it 'contains no result' do
      expect(result).to be_falsey
    end
  end
end

# rubocop:enable Metrics/BlockLength
