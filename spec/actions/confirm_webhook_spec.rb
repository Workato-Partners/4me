# frozen_string_literal: true

RSpec.describe 'actions/confirm_webhook', :vcr do
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  subject(:output) { connector.actions.confirm_webhook(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { JSON.parse(File.read('fixtures/actions/confirm_webhook/input/webhook_verify.json')) }

  let(:action) { connector.actions.confirm_webhook }

  it 'response is empty (http 200)' do
    expect(output).to be_empty
  end
end
