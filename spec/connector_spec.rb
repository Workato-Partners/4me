# frozen_string_literal: true

RSpec.describe 'connector', :vcr do

  # Spec describes the most commons blocks of an connector. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  it { expect(connector).to be_present }

  describe 'test connection' do
    subject(:output) { connector.test(settings) }

    context 'given valid credentials' do
      it 'establishes valid connection' do
        expect(output).to be_present
      end

      it 'contains __schema' do
        expect(output).to include('__schema')
      end

      it 'contains queryType' do
        expect(output[:__schema][:queryType]).to eq('name' => 'Query')
      end

      it 'contains mutationType' do
        expect(output[:__schema][:mutationType]).to eq('name' => 'Mutation')
      end

      it 'contains directives' do
        expect(output[:__schema]).to include('directives')
      end 
    end

    context 'given invalid credentials' do
      let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('invalid_settings.yaml.enc') }

      it 'establishes invalid connection' do
        expect{output}.to raise_error(Workato::Connector::Sdk::RuntimeError)
      end
    end
  end
end
