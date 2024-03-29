# rubocop:disable Metrics/BlockLength, Layout/LineLength
# frozen_string_literal: true

RSpec.describe 'triggers/new_event', :vcr do
  # Spec describes the most commons blocks of a trigger.
  # Depending on the type of your trigger remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # Or add more fine grained tests for each trigger definition block
  let(:trigger) { connector.triggers.new_event }

  describe 'automation rule webhook notification - using SHA-256' do
    subject(:output) { trigger.webhook_notification(input, payload) }
    let(:input) { JSON.parse(File.read('fixtures/triggers/input/webhook_automation_rule_sha256.json')) }
    let(:payload) { JSON.parse(File.read('fixtures/triggers/payload/webhook_automation_rule_sha256.json')) }

    it 'is present' do
      expect(output).to be_present
    end

    it 'contains event, data and payload' do
      expect(output).to include(:event)
      expect(output).to include(:data)
      expect(output).to include(:payload)
    end

    it 'event equals webhook.verify' do
      expect(output[:event]).to eq('webhook.verify')
    end

    it 'payload and data start with https://' do
      expect(output[:data]).to eq([{ 'key' => 'callback', 'value' => 'https://wdc.4me-demo.com/webhooks/3/verify?code=To7jPhA3q80bb8HpsVtxQ2aT&expires_at=1678750777&instance=4me24' }])
      expect(output[:payload]).to include(:callback)
      expect(output[:payload][:callback]).to start_with 'https://'
    end
  end

  describe 'person update webhook notification - using SHA-256' do
    subject(:output) { trigger.webhook_notification(input, payload) }
    let(:input) { JSON.parse(File.read('fixtures/triggers/input/webhook_person_update_sha256.json')) }
    let(:payload) { JSON.parse(File.read('fixtures/triggers/payload/webhook_person_update_sha256.json')) }

    it 'is present' do
      expect(output).to be_present
    end

    it 'contains event, data and no payload' do
      expect(output).to include(:event)
      expect(output).to include(:data)
      expect(output).not_to include(:payload)
    end

    it 'data contains source, audit_line_id and audit_line_nodeID' do
      expect(output[:data]).to eq({ 'audit_line_id' => 239_979_698, 'audit_line_nodeID' => 'NG1lLnFhL0F1ZGl0TGluZS8yMzk5Nzk2OTg', 'source' => '4me API' })
    end
  end

  describe 'dedup' do
    subject(:output) { trigger.dedup(record) }
    let(:record) { { 'account_id' => 'wdc', 'event' => 'automation_rule', 'object_id' => 'abc' } }

    it {
      expect(Time).to receive(:now) { Time.utc(2023, 1, 1, 23, 59, 59) }
      expect(output).to eq('wdc_automation_rule_abc_1672617599.0')
    }
  end

  describe 'output_fields' do
    it 'automation_rule' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'automation_rule' })).to eq(
        [
          { 'name' => 'webhook_id', 'type' => 'integer' },
          { 'name' => 'webhook_nodeID' },
          { 'name' => 'account_id' },
          { 'name' => 'account' },
          { 'name' => 'custom_url' },
          { 'name' => 'name' },
          { 'name' => 'event' },
          { 'name' => 'object_id', 'type' => 'integer' },
          { 'name' => 'object_nodeID' },
          { 'name' => 'person_id', 'type' => 'integer' },
          { 'name' => 'person_nodeID' },
          { 'name' => 'person_name' },
          { 'name' => 'instance_name' },
          { 'name' => 'data', 'type' => 'array', 'of' => 'object', 'properties' => [{ 'name' => 'key' }, { 'name' => 'value' }] },
          { 'name' => 'payload', 'properties' => nil, 'type' => 'object' }
        ]
      )
    end

    it 'out_of_office_period.create' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'out_of_office_period.create' })).to eq(
        [
          { 'name' => 'webhook_id', 'type' => 'integer' },
          { 'name' => 'webhook_nodeID' },
          { 'name' => 'account_id' },
          { 'name' => 'account' },
          { 'name' => 'custom_url' },
          { 'name' => 'name' },
          { 'name' => 'event' },
          { 'name' => 'object_id', 'type' => 'integer' },
          { 'name' => 'object_nodeID' },
          { 'name' => 'person_id', 'type' => 'integer' },
          { 'name' => 'person_nodeID' },
          { 'name' => 'person_name' },
          { 'name' => 'instance_name' },
          { 'name' => 'data', 'properties' => [
            { 'name' => 'callback' },
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'approval_delegate', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'created_at', 'type' => 'date_time' },
            { 'name' => 'effort_class', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'end_at', 'type' => 'date_time' },
            { 'name' => 'person', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'reason' },
            { 'name' => 'source' },
            { 'name' => 'sourceID' },
            { 'name' => 'start_at', 'type' => 'date_time' },
            { 'name' => 'time_allocation', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'localized_name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'updated_at', 'type' => 'date_time' },
            { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
          ], 'type' => 'object' }
        ]
      )
    end

    it 'time_entry.create' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'time_entry.create' })).to eq(
        [
          { 'name' => 'webhook_id', 'type' => 'integer' },
          { 'name' => 'webhook_nodeID' },
          { 'name' => 'account_id' },
          { 'name' => 'account' },
          { 'name' => 'custom_url' },
          { 'name' => 'name' },
          { 'name' => 'event' },
          { 'name' => 'object_id', 'type' => 'integer' },
          { 'name' => 'object_nodeID' },
          { 'name' => 'person_id', 'type' => 'integer' },
          { 'name' => 'person_nodeID' },
          { 'name' => 'person_name' },
          { 'name' => 'instance_name' },
          { 'name' => 'data', 'properties' => [
            { 'name' => 'callback' },
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'connection', 'type' => 'boolean' },
            { 'name' => 'created_at', 'type' => 'date_time' },
            { 'name' => 'customer', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'date', 'type' => 'date' },
            { 'name' => 'deleted', 'type' => 'boolean' },
            { 'name' => 'description', 'type' => 'boolean' },
            { 'name' => 'effort_class', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'note_id', 'type' => 'integer' },
            { 'name' => 'note_nodeID' },
            { 'name' => 'organization', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'person', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'problem', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'project_task', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'request', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'service', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'localized_name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'service_instance', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'started_at', 'type' => 'date_time' },
            { 'name' => 'task', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'time_allocation', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account',
                'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }],
                'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'time_spent', 'type' => 'integer' },
            { 'name' => 'updated_at', 'type' => 'date_time' },
            { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
          ], 'type' => 'object' }
        ]
      )
    end

    let(:app_instance_output_fields) do
      [
        { 'name' => 'webhook_id', 'type' => 'integer' },
        { 'name' => 'webhook_nodeID' },
        { 'name' => 'account_id' },
        { 'name' => 'account' },
        { 'name' => 'custom_url' },
        { 'name' => 'name' },
        { 'name' => 'event' },
        { 'name' => 'object_id', 'type' => 'integer' },
        { 'name' => 'object_nodeID' },
        { 'name' => 'person_id', 'type' => 'integer' },
        { 'name' => 'person_nodeID' },
        { 'name' => 'person_name' },
        { 'name' => 'data', 'properties' => [
          { 'name' => 'callback' },
          { 'name' => 'audit_line_id', 'type' => 'integer' },
          { 'name' => 'audit_line_nodeID' },
          { 'name' => 'app_offering', 'properties' => [{ 'name' => 'reference' }, { 'name' => 'id', 'type' => 'integer' }, { 'name' => 'nodeID' }], 'type' => 'object' },
          { 'name' => 'customer_account_id' },
          { 'name' => 'disabled', 'type' => 'boolean' },
          { 'name' => 'enabled_by_customer', 'type' => 'boolean' },
          { 'name' => 'suspended', 'type' => 'boolean' },
          { 'name' => 'customer_representative', 'properties' => [
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'name' },
            { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
          ], 'type' => 'object' }
        ], 'type' => 'object' }
      ]
    end

    it 'app_instance.create' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'app_instance.create' })).to eq(app_instance_output_fields)
    end

    it 'app_instance.update' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'app_instance.update' })).to eq(app_instance_output_fields)
    end

    it 'app_instance.delete' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'app_instance.delete' })).to eq(app_instance_output_fields)
    end

    it 'app_instance.secrets-update' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'app_instance.secrets-update' })).to eq(
        [
          { 'name' => 'webhook_id', 'type' => 'integer' },
          { 'name' => 'webhook_nodeID' },
          { 'name' => 'account_id' },
          { 'name' => 'account' },
          { 'name' => 'custom_url' },
          { 'name' => 'name' },
          { 'name' => 'event' },
          { 'name' => 'object_id', 'type' => 'integer' },
          { 'name' => 'object_nodeID' },
          { 'name' => 'person_id', 'type' => 'integer' },
          { 'name' => 'person_nodeID' },
          { 'name' => 'person_name' },
          { 'name' => 'data', 'properties' => [
            { 'name' => 'callback' },
            { 'name' => 'audit_line_id', 'type' => 'integer' },
            { 'name' => 'audit_line_nodeID' },
            { 'name' => 'app_offering', 'properties' => [{ 'name' => 'reference' }, { 'name' => 'id', 'type' => 'integer' }, { 'name' => 'nodeID' }], 'type' => 'object' },
            { 'name' => 'customer_account_id' },
            { 'name' => 'application', 'properties' => [{ 'name' => 'nodeID' }, { 'name' => 'client_id' }, { 'name' => 'client_secret' }], 'type' => 'object' },
            { 'name' => 'policy', 'properties' => [{ 'name' => 'nodeID' }, { 'name' => 'audience' }, { 'name' => 'algorithm' }, { 'name' => 'public_key' }], 'type' => 'object' }
          ], 'type' => 'object' }
        ]
      )
    end

    it 'default' do
      expect(trigger.output_fields(settings, { 'event_selection' => 'other_type' })).to eq(
        [
          { 'name' => 'webhook_id', 'type' => 'integer' },
          { 'name' => 'webhook_nodeID' },
          { 'name' => 'account_id' },
          { 'name' => 'account' },
          { 'name' => 'custom_url' },
          { 'name' => 'name' },
          { 'name' => 'event' },
          { 'name' => 'object_id', 'type' => 'integer' },
          { 'name' => 'object_nodeID' },
          { 'name' => 'person_id', 'type' => 'integer' },
          { 'name' => 'person_nodeID' },
          { 'name' => 'person_name' },
          { 'name' => 'instance_name' },
          { 'name' => 'data', 'properties' => [
            { 'name' => 'callback' },
            { 'name' => 'audit_line_id', 'type' => 'integer' },
            { 'name' => 'audit_line_nodeID' },
            { 'name' => 'note_id', 'type' => 'integer' },
            { 'name' => 'note_nodeID' },
            { 'name' => 'source' },
            { 'name' => 'sourceID' },
            { 'name' => 'status' },
            { 'name' => 'previous_status' },
            { 'name' => 'team', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'sourceID' },
              { 'name' => 'disabled', 'type' => 'boolean' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'member', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'sourceID' },
              { 'name' => 'disabled', 'type' => 'boolean' },
              { 'name' => 'account', 'properties' => [{ 'name' => 'id' }, { 'name' => 'name' }], 'type' => 'object' }
            ], 'type' => 'object' }
          ], 'type' => 'object' }
        ]
      )
    end
  end
end

# rubocop:enable Metrics/BlockLength, Layout/LineLength
