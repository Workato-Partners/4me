# frozen_string_literal: true

RSpec.describe 'methods/apply_field_description', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:apply_field_description) { connector.methods.apply_field_description(connection, field, description) }

  context 'applies field description' do
    let(:connection) { {} }
    let(:field) { {} }
    let(:description) { 'foo **bar** test' }

    it 'adds a hint to the field' do
      apply_field_description
      expect(field[:hint]).to eq('foo &#x2022; test')
    end
  end

  context 'does nothing when there is no description' do
    let(:connection) { {} }
    let(:field) { {} }
    let(:description) { '' }

    it 'adds a hint to the field' do
      apply_field_description
      expect(field.key?(:hint)).to eq false
    end
  end
end
