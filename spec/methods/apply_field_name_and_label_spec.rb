# frozen_string_literal: true

RSpec.describe 'methods/apply_field_name_and_label', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

    describe "apply_field_name_and_label" do
    let(:field) { { name: 'field_name', label: 'Field Label', isDeprecated: false } }
    let(:toggle_field) { { name: 'toggle_field_name', label: 'Toggle Field Label' } }
  
    subject do
      field[:toggle_field] = toggle_field
      connector.methods.apply_field_name_and_label(nil, field, 'prefix', 'name')
    end
  
    it 'updates the name of the field and toggle field' do
      expect(subject[:name]).to eq('prefix_name')
      expect(subject[:toggle_field][:name]).to eq('prefix_name')
    end
  
    it 'updates the label of the field and toggle field' do
      expect(subject[:label]).to eq('Name')
      expect(subject[:toggle_field][:label]).to eq('Name')
    end
  
    it 'sets the sticky flag to true' do
      expect(subject[:sticky]).to eq(true)
    end
  
    context 'when name_prefix is blank' do
      subject do
        field[:toggle_field] = toggle_field
        connector.methods.apply_field_name_and_label(nil, field, '', 'name')
      end
  
      it 'updates the name of the field and toggle field' do
        expect(subject[:name]).to eq('name')
        expect(subject[:toggle_field][:name]).to eq('name')
      end
    end
  end
end
