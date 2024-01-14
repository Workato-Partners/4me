# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

RSpec.describe 'actions/upload_attachment', :vcr do
  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  subject(:output) { connector.actions.upload_attachment(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.upload_attachment }

  describe 'execute' do
    let(:input) do
      {
        'account' => 'wdc',
        'file_name' => 'hello world.txt',
        'content_type' => 'text/plain',
        'file_data' => '0x48656C6C6F20776F726C6421'
      }
    end
    subject(:output) { action.execute(settings, input) }

    it 'contains a key' do
      expect(output).to be_present
      expect(output).to include('key')
    end
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(object_definitions) }
    let(:object_definitions) { {} }
    it {
      is_expected.to eq([
                          {
                            'name' => 'account',
                            'label' => 'Account ID',
                            'optional' => false,
                            'sticky' => true,
                            'control_type' => 'text',
                            'hint' => 'The 4me account identifier.',
                            'default' => 'wdc'
                          },
                          {
                            'name' => 'file_name',
                            'label' => 'File name',
                            'optional' => false
                          },
                          {
                            'name' => 'content_type',
                            'label' => 'Content-Type',
                            'optional' => false
                          },
                          {
                            'name' => 'file_data',
                            'label' => 'File content',
                            'optional' => false
                          }
                        ])
    }
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields }
    let(:object_definitions) { {} }
    it {
      is_expected.to eq([
                          {
                            'hint' => 'Reference object key for the uploaded file.',
                            'name' => 'key',
                            'label' => 'Key'
                          }
                        ])
    }
  end
end

# rubocop:enable Metrics/BlockLength
