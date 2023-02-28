# frozen_string_literal: true

RSpec.describe 'methods/is_primitive_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.is_primitive_type(type) }

  context 'NON_NULL of type SCALAR' do
    let(:type) { { 'kind' => 'NON_NULL', 'ofType' => { 'kind' => 'SCALAR' } } }
    it { is_expected.to eq true }
  end

  context 'NON_NULL of type ENUM' do
    let(:type) { { 'kind' => 'NON_NULL', 'ofType' => { 'kind' => 'ENUM' } } }
    it { is_expected.to eq true }
  end

  context 'SCALAR' do
    let(:type) { { 'kind' => 'SCALAR' } }
    it { is_expected.to eq true }
  end

  context 'ENUM' do
    let(:type) { { 'kind' => 'ENUM' } }
    it { is_expected.to eq true }
  end

  context 'OBJECT' do
    let(:type) { { 'kind' => 'OBJECT' } }
    it { is_expected.to eq false }
  end

  context 'INTERFACE' do
    let(:type) { { 'kind' => 'INTERFACE' } }
    it { is_expected.to eq false }
  end

end
