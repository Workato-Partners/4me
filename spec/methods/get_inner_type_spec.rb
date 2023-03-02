# frozen_string_literal: true

RSpec.describe 'methods/get_inner_type', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.get_inner_type(type) }

  context 'recursive in NON_NULL and LIST' do
    let(:type) { { 'kind' => 'LIST', 'ofType' => { 'kind' => 'NON_NULL', 'ofType' => { 'kind' => 'ENUM' } } } }
    it { is_expected.to eq({ 'kind' => 'ENUM' }) }
  end

  context 'SCALAR' do
    let(:type) { { 'kind' => 'SCALAR' } }
    it { is_expected.to eq({ 'kind' => 'SCALAR' }) }
  end
end
