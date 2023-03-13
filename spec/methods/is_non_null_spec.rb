# frozen_string_literal: true

RSpec.describe 'methods/is_non_null', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.is_non_null(type) }

  context 'NON_NULL' do
    let(:type) { { 'kind' => 'NON_NULL' } }
    it { is_expected.to eq true }
  end

  context 'LIST with NON_NULL' do
    let(:type) { { 'kind' => 'LIST', 'ofType' => { 'kind' => 'NON_NULL' } } }
    it { is_expected.to eq true }
  end

  context 'SCALAR' do
    let(:type) { { 'kind' => 'SCALAR' } }
    it { is_expected.to eq false }
  end

  context 'LIST with SCALAR' do
    let(:type) { { 'kind' => 'LIST', 'ofType' => { 'kind' => 'SCALAR' } } }
    it { is_expected.to eq false }
  end
end
