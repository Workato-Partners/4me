# frozen_string_literal: true

RSpec.describe 'methods/format_field_hint', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  describe 'hint with href' do
    let(:result) { connector.methods.format_field_hint(settings, 'Query fields will be matched against the application schema. <a href="https://developer.4me.com/graphql/" target="_blank">Learn more</a>') }

    it 'contains result' do
      expect(result).to be_present
      expect(result).to eq('Query fields will be matched against the application schema. <a href=<b>https://developer.4me.com/graphql/</b> target=<b>_blank</b>>Learn more</a>')
    end
  end

  describe 'format field hint' do
    let(:result) { connector.methods.format_field_hint(settings, '<br>Line1</br>\n<br>Line2</br>') }

    it 'multiline hint' do
      expect(result).to be_present
      expect(result).to eq('<br>Line1</br><br><br>Line2</br. See documentation for details.')
    end
  end
end
