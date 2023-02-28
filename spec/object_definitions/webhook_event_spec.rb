# frozen_string_literal: true

RSpec.describe 'object_definition/webhook_event', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:object_definition) { connector.object_definitions.webhook_event }

  describe 'fields automation_rule' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { 'event_selection' => 'automation_rule' } }

    it 'returns schema definition' do
      expect(schema_fields).to eq([
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
        { 'name' => 'payload', 'properties' => nil, 'type' => 'object'}
        ])
      end
  end

  describe 'fields out_of_office_period' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { 'event_selection' => 'out_of_office_period.create' } }

    it 'returns schema definition' do
      expect(schema_fields).to eq([
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
        { 'name' => 'data', 'properties'=> [
          { 'name' => 'callback' },
          { 'name' => 'id', 'type' => 'integer' },
          { 'name' => 'nodeID' },
          { 'name' => 'approval_delegate', 'properties'=> [
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'name' },
            { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
          ], 'type' => 'object' },
            { 'name' => 'created_at', 'type' => 'date_time' },
            { 'name' => 'effort_class', 'properties' => [
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'name' },
            { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'end_at', 'type' => 'date_time' },
            { 'name' => 'person', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
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
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
              ], 'type' => 'object' },
            { 'name' => 'updated_at', 'type' => 'date_time' },
            { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
          ], 'type' => 'object' }
         ])
    end
  end

  describe 'fields time_entry' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { 'event_selection' => 'time_entry.create' } }
    it 'returns schema definition' do
      expect(schema_fields).to eq(
        [ { 'name' => 'webhook_id', 'type' => 'integer' },
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
          { 'name' => 'data',
           'properties'=> [
            { 'name' => 'callback' },
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'connection', 'type' => 'boolean' },
            { 'name' => 'created_at', 'type' => 'date_time' },
            { 'name' => 'customer', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'date', 'type' => 'date' },
            { 'name' => 'deleted', 'type' => 'boolean' },
            { 'name' => 'description', 'type' => 'boolean' },
            { 'name' => 'effort_class', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'note_id', 'type' => 'integer' },
            { 'name' => 'note_nodeID' },
            { 'name' => 'organization', 'properties' => [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
            ], 'type' => 'object' },
            { 'name' => 'person', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
            { 'name' => 'problem', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
             { 'name' => 'project_task', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
            { 'name' => 'request', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
             { 'name' => 'service', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'localized_name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
             { 'name' => 'service_instance', 'properties' =>[
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'name' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
             { 'name' => 'started_at', 'type' => 'date_time' },
             { 'name' => 'task', 'properties'=> [
              { 'name' => 'id', 'type' => 'integer' },
              { 'name' => 'nodeID' },
              { 'name' => 'subject' },
              { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' },
             { 'name' => 'time_allocation', 'properties' =>
               [ { 'name' => 'id', 'type' => 'integer' },
                { 'name' => 'nodeID' },
                { 'name' => 'name' },
                { 'name' => 'account',
                 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ],
                 'type' => 'object' } ],
              'type' => 'object' },
             { 'name' => 'time_spent', 'type' => 'integer' },
             { 'name' => 'updated_at', 'type' => 'date_time' },
             { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
             ], 'type' => 'object' }
            ])
    end
  end

  describe 'fields default' do
    subject(:schema_fields) { object_definition.fields(settings, config_fields) }
    let(:config_fields) { { 'event_selection' => 'project.create' } }

    it 'returns schema definition' do
      expect(schema_fields).to eq([
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
        { 'name' => 'data', 'properties'=> [ 
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
            { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' }
          ], 'type' => 'object' },
          { 'name' => 'member', 'properties' => [
            { 'name' => 'id', 'type' => 'integer' },
            { 'name' => 'nodeID' },
            { 'name' => 'name' },
            { 'name' => 'sourceID' },
            { 'name' => 'disabled', 'type' => 'boolean' },
            { 'name' => 'account', 'properties' => [ { 'name' => 'id' }, { 'name' => 'name' } ], 'type' => 'object' } 
          ], 'type' => 'object' }
        ], 'type' => 'object' }
    ])
    end
  end
end
