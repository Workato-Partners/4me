# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

RSpec.describe 'pick_lists/webhook_events', :vcr do
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:pick_list) { connector.pick_lists.webhook_events(settings) }

  it 'returns the list of webhook events' do
    expect(pick_list).to eq(
      [
        ['App instance create', 'app_instance.create'],
        ['App instance delete', 'app_instance.delete'],
        ['App instance secrets update', 'app_instance.secrets-update'],
        ['App instance update', 'app_instance.update'],
        ['Automation rule', 'automation_rule'],
        ['Broadcast create', 'broadcast.create'],
        ['Broadcast update', 'broadcast.update'],
        ['Configuration item create', 'ci.create'],
        ['Configuration item update', 'ci.update'],
        ['Contract create', 'contract.create'],
        ['Contract update', 'contract.update'],
        ['First line support agreement create', 'flsa.create'],
        ['First line support agreement create update', 'flsa.update'],
        ['Knowledge article create', 'knowledge_article.create'],
        ['Knowledge article update', 'knowledge_article.update'],
        ['Organization create', 'organization.create'],
        ['Organization update', 'organization.update'],
        ['Out of office period create', 'out_of_office_period.create'],
        ['Out of office period delete', 'out_of_office_period.delete'],
        ['Out of office period update', 'out_of_office_period.update'],
        ['Person create', 'person.create'],
        ['Person update', 'person.update'],
        ['Problem create', 'problem.create'],
        ['Problem manager changed', 'problem.manager-changed'],
        ['Problem member changed', 'problem.member-changed'],
        ['Problem note added', 'problem.note-added'],
        ['Problem status changed', 'problem.status-changed'],
        ['Problem team changed', 'problem.team-changed'],
        ['Problem update', 'problem.update'],
        ['Product create', 'product.create'],
        ['Product update', 'product.update'],
        ['Project create', 'project.create'],
        ['Project manager changed', 'project.manager-changed'],
        ['Project note added', 'project.note-added'],
        ['Project status changed', 'project.status-changed'],
        ['Project task create', 'project_task.create'],
        ['Project task delete', 'project_task.delete'],
        ['Project task note added', 'project_task.note-added'],
        ['Project task status changed', 'project_task.status-changed'],
        ['Project task update', 'project_task.update'],
        ['Project update', 'project.update'],
        ['Release create', 'release.create'],
        ['Release manager changed', 'release.manager-changed'],
        ['Release note added', 'release.note-added'],
        ['Release update', 'release.update'],
        ['Request agile board column changed', 'request.agile-board-column-changed'],
        ['Request create', 'request.create'],
        ['Request major incident status changed', 'request.major-incident-status-changed'],
        ['Request member changed', 'request.member-changed'],
        ['Request note added', 'request.note-added'],
        ['Request status changed', 'request.status-changed'],
        ['Request team changed', 'request.team-changed'],
        ['Request update', 'request.update'],
        ['Risk create', 'risk.create'],
        ['Risk manager changed', 'risk.manager-changed'],
        ['Risk note added', 'risk.note-added'],
        ['Risk status changed', 'risk.status-changed'],
        ['Risk update', 'risk.update'],
        ['Service create', 'service.create'],
        ['Service instance create', 'service_instance.create'],
        ['Service instance update', 'service_instance.update'],
        ['Service offering create', 'service_offering.create'],
        ['Service offering update', 'service_offering.update'],
        ['Service update', 'service.update'],
        ['Service level agreement create', 'sla.create'],
        ['Service level agreement update', 'sla.update'],
        ['Task create', 'task.create'],
        ['Task member changed', 'task.member-changed'],
        ['Task note added', 'task.note-added'],
        ['Task status changed', 'task.status-changed'],
        ['Task team changed', 'task.team-changed'],
        ['Task update', 'task.update'],
        ['Team create', 'team.create'],
        ['Team update', 'team.update'],
        ['Time entry create', 'time_entry.create'],
        ['Time entry delete', 'time_entry.delete'],
        ['Time entry update', 'time_entry.update'],
        # ['Webhook verify','webhook.verify'],
        ['Workflow create', 'workflow.create'],
        ['Workflow manager changed', 'workflow.manager-changed'],
        ['Workflow note added', 'workflow.note-added'],
        ['Workflow status changed', 'workflow.status-changed'],
        ['Workflow update', 'workflow.update']
      ]
    )
  end
end

# rubocop:enable Metrics/BlockLength
