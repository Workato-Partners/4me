# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

RSpec.describe 'methods/apply_field_default_value', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:connection) { {} }
  subject(:apply_field_default_value) do
    connector.methods.apply_field_default_value(nil, field, default_value)
  end

  context 'applies field default string value' do
    let(:field) { { type: :string, hint: 'hint', optional: false } }
    let(:default_value) { 'Foo' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default]).to eq('Foo')
    end
  end

  context 'applies field default integer value' do
    let(:field) { { type: :integer, hint: 'hint', optional: false } }
    let(:default_value) { '1024' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default]).to eq(1024)
    end
  end

  context 'applies field default boolean value' do
    let(:field) { { type: :boolean, hint: 'hint', optional: false } }
    let(:default_value) { 'true' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default]).to eq(true)
    end
  end

  context 'applies field default datetime value' do
    let(:field) { { type: :datetime, hint: 'hint', optional: false } }
    let(:default_value) { '1980-01-02T11:23:12Z' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default]).to eq('1980-01-02 11:23:12 +0000')
    end
  end

  context 'applies field default date value' do
    let(:field) { { type: :date, hint: 'hint', optional: false } }
    let(:default_value) { '1980-01-02' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default].to_s).to eq('1980-01-02')
    end
  end

  context 'applies field default object value' do
    let(:field) { { type: :object, hint: 'hint', optional: false } }
    let(:default_value) { '1980-01-02' }

    it 'adds default value to the field' do
      apply_field_default_value
      expect(field[:default].to_s).to be_blank
    end
  end
end

# rubocop:enable Metrics/BlockLength
