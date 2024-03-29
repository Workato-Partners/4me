# frozen_string_literal: true

RSpec.describe 'methods/apply_field_description', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:connection) { {} }
  let(:field) { {} }

  subject(:apply_field_description) { connector.methods.apply_field_description(connection, field, description) }

  context 'applies field description' do
    let(:description) { '* foo bar test' }

    it 'adds a hint to the field' do
      apply_field_description
      expect(field[:hint]).to eq('&#x2022; foo bar test')
    end
  end

  context 'does nothing when there is no description' do
    let(:description) { '' }

    it 'adds a hint to the field' do
      apply_field_description
      expect(field.key?(:hint)).to eq false
    end
  end
end
