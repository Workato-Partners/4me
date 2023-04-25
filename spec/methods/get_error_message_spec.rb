# frozen_string_literal: true

RSpec.describe 'methods/get_error_message', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { JSON.parse(File.read('fixtures/actions/get_error_message/error_message.json')) }

  subject(:result) { connector.methods.get_error_message(settings, input) }

  describe 'test output' do
    it 'contains result' do
      expect(result).to be_present
      expect(result).to eq("Field 'field_does_not_exists' doesn't exist on type 'Person'")
    end
  end
end
