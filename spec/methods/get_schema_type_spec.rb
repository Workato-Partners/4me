# frozen_string_literal: true

RSpec.describe 'methods/get_schema_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.get_schema_type(settings, nil, 'OBJECT', 'ConfigurationItem') }

  describe 'get schema type' do
    it 'contains a response' do
      expect(result).to be_present
    end

    it 'contains fields and account' do
      expect(result).to include('fields')
    end

    it 'contains account, label, createdAt and updatedAt' do
      expect(result[:fields].any? { |hash| hash['name'] == 'account' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'label' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'createdAt' }).to be_truthy
      expect(result[:fields].any? { |hash| hash['name'] == 'updatedAt' }).to be_truthy
    end
  end
end
