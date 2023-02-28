# frozen_string_literal: true

RSpec.describe 'methods/labelize', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.labelize(name, deprecated) }

  context 'non-deprecated' do
    let(:deprecated) { false }

    context 'labelizes a symbol' do
      let(:name) { :problem_id }
      it { is_expected.to eq 'Problem ID' }
    end

    context 'capitalizes id to ID' do
      let(:name) { :id }
      it { is_expected.to eq 'ID' }
    end

    context 'capitalizes id at start to ID' do
      let(:name) { 'id sequence' }
      it { is_expected.to eq 'ID sequence' }
    end

    context 'capitalizes id at end to ID' do
      let(:name) { 'problem id' }
      it { is_expected.to eq 'Problem ID' }
    end

    context 'capitalizes id mid-string to ID' do
      let(:name) { 'problem id sequence' }
      it { is_expected.to eq 'Problem ID sequence' }
    end

    context 'capitalizes first letter' do
      let(:name) { 'identifier' }
      it { is_expected.to eq 'Identifier' }
    end

    context 'splits strings at capital letters' do
      let(:name) { 'requestIdSeq' }
      it { is_expected.to eq 'Request ID seq' }
    end

    context 'strips, strips out non-words characters, and strips consequtive spaces to one space' do
      let(:name) { "     request id\nproblem    id\nwant-this_as@!#well9    " }
      it { is_expected.to eq 'Request ID problem ID want this as well9' }
    end

    context 'downcases initial letter at word boundaries' do
      let(:name) { 'Problem Request Risk JWT Token' }
      it { is_expected.to eq 'Problem request risk JWT token' }
    end
  end

  context 'deprecated' do
    let(:name) { :risk_id }
    let(:deprecated) { true }
    it { is_expected.to eq 'Risk ID (deprecated)' }
  end

end
