# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/IfUnlessModifier
# rubocop:disable Style/PreferredHashMethods
# rubocop:disable Style/SymbolProc
# rubocop:disable Lint/UnusedBlockArgument

# frozen_string_literal: true

{
  title: '4me',

  connection: {
    fields: [
      {
        name: 'account',
        label: '4me Account',
        optional: false,
        hint: 'The 4me account identifier'
      },
      {
        name: 'instance',
        label: '4me Instance',
        hint: 'The 4me instance',
        optional: false,
        control_type: 'select',
        options: [
          ['Production', 'production'],
          ['Quality Assurance', 'quality_assurance'],
          ['Demo', 'demo'],
          ['Custom domain', 'custom_domain']
        ]
      },
      {
        ngIf: 'input.instance == "production" || input.instance == "quality_assurance"',
        name: 'region',
        label: '4me region',
        hint: 'The 4me region',
        optional: false,
        control_type: 'select',
        options: [
          ['Europe', 'default'],
          ['Australia', 'au'],
          ['United Kingdom', 'uk'],
          ['United States', 'us'],
          ['Switzerland', 'ch']
        ]
      },
      {
        ngIf: 'input.instance == "custom_domain"',
        name: 'custom_domain_name',
        label: 'Domain name',
        hint: 'The 4me domain name',
        optional: false,
        control_type: 'text'
      },
      {
        name: 'auth_method',
        control_type: 'select',
        hint: 'The 4me authentication method',
        optional: false,
        pick_list: [
          ['Personal Access Token', 'bearer'],
          ['OAuth2 (Client Credentials Grant)', 'oauth2_client_credentials']
        ]
      },
      {
        ngIf: 'input.auth_method == "bearer"',
        name: 'bearer_token',
        label: 'Personal Access Token',
        hint: 'The 4me bearer token',
        control_type: :password,
        optional: false
      },
      {
        ngIf: 'input.auth_method == "oauth2_client_credentials"',
        name: 'client_id',
        label: 'Client ID',
        optional: false,
        hint: 'The 4me OAuth 2.0 client ID'
      },
      {
        ngIf: 'input.auth_method == "oauth2_client_credentials"',
        name: 'client_secret',
        label: 'Client secret',
        optional: false,
        control_type: :password,
        hint: 'The 4me OAuth 2.0 client secret'
      }
    ],

    authorization: {
      type: 'custom_auth',

      acquire: lambda do |connection|
        instance = connection['instance']
        region = connection['region']
        custom_domain_name = connection['custom_domain_name']

        token_url =
          case instance
          when 'production'
            case region
            when 'au'
              'https://oauth.au.4me.com/token'
            when 'uk'
              'https://oauth.uk.4me.com/token'
            when 'us'
              'https://oauth.us.4me.com/token'
            when 'ch'
              'https://oauth.ch.4me.com/token'
            else
              'https://oauth.4me.com/token'
            end
          when 'quality_assurance'
            case region
            when 'au'
              'https://oauth.au.4me.qa/token'
            when 'uk'
              'https://oauth.uk.4me.qa/token'
            when 'us'
              'https://oauth.us.4me.qa/token'
            when 'ch'
              'https://oauth.ch.4me.qa/token'
            else
              'https://oauth.4me.qa/token'
            end
          when 'demo'
            'https://oauth.4me-demo.com/token'
          else
            "https://oauth.#{custom_domain_name}/token"
          end

        request = post(token_url)
        request.headers('x-4me-Account': connection['account'])
        payload = {
          grant_type: 'client_credentials',
          client_id: connection['client_id'],
          client_secret: connection['client_secret']
        }
        request = request.payload(payload)
        response = request.request_format_www_form_urlencoded

        {
          access_token: response['access_token']
        }
      end,

      refresh_on: [401, 403],

      apply: lambda do |connection|
        if current_url.include?('https://graphql.')
          case connection['auth_method']
          when 'bearer'
            bearer_token = connection['bearer_token']
            headers(Authorization: "Bearer #{bearer_token}") unless bearer_token.blank?
          when 'oauth2_client_credentials'
            access_token = connection['access_token']
            headers(Authorization: "Bearer #{access_token}") unless access_token.blank?
          end
        end
      end
    },

    base_uri: lambda do |connection|
      instance = connection['instance']
      region = connection['region']
      custom_domain_name = connection['custom_domain_name']

      case instance
      when 'production'
        case region
        when 'au'
          'https://graphql.au.4me.com'
        when 'uk'
          'https://graphql.uk.4me.com'
        when 'us'
          'https://graphql.us.4me.com'
        when 'ch'
          'https://graphql.ch.4me.com'
        else
          'https://graphql.4me.com'
        end
      when 'quality_assurance'
        case region
        when 'au'
          'https://graphql.au.4me.qa'
        when 'uk'
          'https://graphql.uk.4me.qa'
        when 'us'
          'https://graphql.us.4me.qa'
        when 'ch'
          'https://graphql.ch.4me.qa'
        else
          'https://graphql.4me.qa'
        end
      when 'demo'
        'https://graphql.4me-demo.com'
      else
        "https://graphql.#{custom_domain_name}"
      end
    end
  },

  # Tests the connection to the server by performing
  # a simple introspection query.
  test: lambda do |connection|
    call(
      'run_gql',
      connection,
      "{
        __schema {
          queryType {
            name
          }
        }
      }",
      nil,
      nil,
      connection['account']
    )
  end,

  webhook_keys: lambda do |params, headers, payload|
    jwt = payload&.[]('jwt')
    if jwt.present?
      jwt.split('.')[1].decode_urlsafe_base64.as_utf8.match(/"webhook_nodeID":"([^"]*)"/)[1]
    end
  end,

  actions: {
    query: {
      title: 'Query records',
      subtitle: 'Retrieve one or more records, e.g. people, configuration items, requets and workflows, in 4me.',
      help: {
        body: 'Use this action to get a single record or search all records that matches your search criteria.<br>'\
              'The ID value in the 4me connector and the GraphQL API is the same as the nodeID value in '\
              '4me automation rules or in the 4me REST API.',
        learn_more_url: 'https://developer.4me.com/graphql/',
        learn_more_text: 'Learn more'
      },
      display_priority: 50,
      description: lambda do |input, picklist_label|
        name = input['object']
        name = name[0..-3] if name&.ends_with?('{}')
        label = name&.labelize&.downcase
        "Query <span class='provider'>" \
          "#{label || 'records'}</span> via " \
          "<span class='provider'>4me</span>"
      end,
      input_fields: lambda do |object_definitions|
        object_definitions['query_input']
      end,
      execute: lambda do |connection, input, eis, eos|
        call('action_execute', connection, input, eis, eos, 'query')
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['query_output']
      end
    },

    mutation: {
      title: 'Mutate records',
      subtitle: 'Create, update or delete a record, e.g. people, configuration items, requets and workflows, in 4me.',
      help: {
        body: 'Use this action to create, delete or update a record.<br>'\
              'The ID value in the 4me connector and the GraphQL API is the same as the nodeID value in '\
              '4me automation rules or in the 4me REST API.',
        learn_more_url: 'https://developer.4me.com/graphql/',
        learn_more_text: 'Learn more'
      },
      display_priority: 40,
      description: lambda do |input, picklist_label|
        name = input['object']
        name = name[0..-3] if name&.ends_with?('{}')
        label = name&.labelize&.downcase
        if label.present?
          "Perform <span class='provider'>" \
            "#{label}</span> via " \
            "<span class='provider'>4me</span>"
        else
          "Mutate <span class='provider'>" \
            'records</span> via ' \
            "<span class='provider'>4me</span>"
        end
      end,
      input_fields: lambda do |object_definitions|
        object_definitions['mutation_input']
      end,
      execute: lambda do |connection, input, eis, eos|
        call('action_execute', connection, input, eis, eos, 'mutation')
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['mutation_output']
      end
    },

    custom_operation: {
      title: 'Custom action',
      subtitle: 'Provide and run a custom GraphQL operation, e.g. create a person or query people, in 4me.',
      help: {
        body: 'Use this action to run any 4me GraphQL operation.<br>'\
              'The ID value in the 4me connector and the GraphQL API is the same as the nodeID value in '\
              '4me automation rules or in the 4me REST API.',
        learn_more_url: 'https://developer.4me.com/graphql/',
        learn_more_text: 'Learn more'
      },
      display_priority: 30,
      description: lambda do |input, picklist_label|
        operation_name = input['operation_name']
        if operation_name.blank?
          "Run <span class='provider'>" \
          'operation</span> via ' \
          "<span class='provider'>4me</span>"
        else
          "Run <span class='provider'>" \
          "#{operation_name.labelize.downcase}</span> via " \
          "<span class='provider'>4me</span>"
        end
      end,
      input_fields: lambda do |object_definitions|
        object_definitions['custom_operation_input']
      end,
      execute: lambda do |connection, input, eis, eos|
        call('execute_custom_operation', connection, input, eis, eos)
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['custom_operation_output']
      end
    },

    upload_attachment: {
      title: 'Upload attachment',
      subtitle: 'Upload a file which can be referenced later as an attachment or embedded' \
                ' image in 4me.',
      help: {
        body: 'Upload a file which can be referenced later as an attachment or embedded image,' \
              ' e.g. note attachments, in 4me.'
      },
      display_priority: 20,
      description: 'Upload a file which can be referenced later as an attachment or embedded' \
                   ' image in 4me.',
      input_fields: lambda do |object_definitions|
        object_definitions['file_upload_input']
      end,

      execute: lambda do |connection, input|
        attachment_storage = call(
          'run_gql',
          connection,
          'query {attachmentStorage {providerParameters, uploadUri}}',
          nil,
          nil,
          input['account']
        )['attachmentStorage']
        provider_parameters = attachment_storage['providerParameters']

        response = post(attachment_storage['uploadUri'])
                   .request_format_multipart_form
                   .payload(
                     'Content-Type': input['content_type'],
                     'acl': provider_parameters['acl'],
                     'key': provider_parameters['key'].sub('${filename}', input['file_name']),
                     'policy': provider_parameters['policy'],
                     'success_action_status': provider_parameters['success_action_status'],
                     'x-amz-algorithm': provider_parameters['x-amz-algorithm'],
                     'x-amz-credential': provider_parameters['x-amz-credential'],
                     'x-amz-date': provider_parameters['x-amz-date'],
                     'x-amz-server-side-encryption': provider_parameters['x-amz-server-side-encryption'],
                     'x-amz-signature': provider_parameters['x-amz-signature'],
                     'file': input['file_data']
                   )
                   .response_format_xml
                   .after_error_response do |code, body, headers, message|
          error(body['Error'][0]['Message'][0]['content!'])
        end

        response.after_response do |code, body, headers, message|
          { key: body['PostResponse'][0]['Key'][0]['content!'] }
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['file_upload_output']
      end,

      sample_output: lambda do |object_definitions|
        {
          key: 'attachments/5/2023/03/02/605/1677726321..../helloworld.txt'
        }
      end
    }
  },

  object_definitions: {
    query_input: {
      fields: lambda do |connection, input|
        call('build_action_input_fields', connection, input, 'query')
      end
    },

    query_output: {
      fields: lambda do |connection, input|
        call('build_action_output_fields', connection, input, 'query')
      end
    },

    mutation_input: {
      fields: lambda do |connection, input|
        call('build_action_input_fields', connection, input, 'mutation')
      end
    },

    mutation_output: {
      fields: lambda do |connection, input|
        call('build_action_output_fields', connection, input, 'mutation')
      end
    },

    custom_operation_input: {
      fields: lambda do |connection, input|
        # collect problem messages here
        problems = []
        report_problem = lambda do |msg|
          problems << msg
        end

        # Custom query documents
        documents = []
        query = input['query']
        if query.present?
          parsed_query = call(
            'parse_graphql',
            report_problem,
            query
          )
          documents = parsed_query[:documents]
        end

        query_field = {
          name: 'query',
          label: 'Query',
          hint: 'Query fields will be matched against the application schema.<br>'\
                'The operation type and operation name are required.<br>'\
                'Every variable, including those that are empty or null, will be submitted.',
          multiline: true,
          control_type: 'text-area',
          optional: false,
          change_on_blur: true,
          extends_schema: true,
          schema_neutral: false
        }
        fields = [query_field]

        # Operation names
        operation_names = documents.map { |doc| doc[:operation_name] }.compact

        # if there is more than 1 operation, always ask for the operation name
        if documents.length > 1
          operation_name_hint = 'Since the document contains multiple operations, ' \
                                'you must specify which one to perform.'
          if operation_names.length != documents.length
            operation_name_hint = "#{operation_name_hint} " \
                                  'In case you are missing an operation, ' \
                                  'you have to provide a operation name in the GraphQL document. ' \
                                  '<a href="https://graphql.org/learn/queries/#operation-name" ' \
                                  'target="_blank">Learn more</a>'
          end
          fields << {
            name: 'operation_name',
            label: 'Operation to perform',
            hint: operation_name_hint,
            control_type: :select,
            pick_list: operation_names.map do |name|
              [
                call('labelize', name, nil),
                name
              ]
            end,
            extends_schema: true,
            schema_neutral: false,
            optional: false
          }

          operation_name = input['operation_name']
          if operation_name.present?
            operation = documents.find do |doc|
              doc[:operation_name] == operation_name
            end
          end
        else
          operation = documents.first
        end
        if operation.present?
          variable_fields = call(
            'create_custom_operation_variables_input_fields',
            connection,
            report_problem,
            operation
          )
          variable_fields&.each do |f|
            fields << f
          end
          call(
            'create_custom_operation_output_fields',
            connection,
            report_problem,
            operation
          )
        end
        if problems.present?
          hint = query_field[:hint]
          hint = "#{hint}<br>" unless hint.blank?
          query_field[:hint] = "#{hint}<br>" \
                               '<b>Problems</b><br>' \
                               "#{problems.join('<br>')}"
        end

        fields.insert(0, {
                        name: 'account',
                        label: 'Account ID',
                        sticky: true,
                        default: connection['account'],
                        optional: false,
                        control_type: 'text',
                        hint: 'The 4me account identifier'
                      })
        fields
      end
    },

    custom_operation_output: {
      fields: lambda do |connection, input|
        parsed_query = call(
          'parse_graphql',
          nil,
          input['query']
        )
        docs = parsed_query&.[](:documents)
        operation = docs.find { |doc| doc[:operation_name] == input['operation_name'] } || docs.first if docs.present?
        if operation.present?
          output_fields = call(
            'create_custom_operation_output_fields',
            connection,
            nil,
            operation
          )
          output_fields.insert(0, call('build_output_rate_limit_fields'))
          output_fields
        else
          []
        end
      end
    },

    file_upload_input: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          {
            name: 'account',
            label: 'Account ID',
            sticky: true,
            default: connection['account'],
            optional: false,
            control_type: 'text',
            hint: 'The 4me account identifier'
          },
          {
            name: 'file_name',
            label: 'File name',
            optional: false
          },
          {
            name: 'content_type',
            label: 'Content-Type',
            optional: false
          },
          {
            name: 'file_data',
            label: 'File content',
            optional: false
          }
        ]
      end
    },

    file_upload_output: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          {
            name: 'key',
            label: 'Key',
            hint: 'Reference object key for the uploaded file.'
          }
        ]
      end
    },

    account: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          { name: 'id' },
          { name: 'name' }
        ]
      end
    },

    common_with_name: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          { name: 'id', type: 'integer' },
          { name: 'nodeID' },
          { name: 'name' },
          { name: 'account', type: 'object', properties: object_definitions['account'] }
        ]
      end
    },

    common_with_subject: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          { name: 'id', type: 'integer' },
          { name: 'nodeID' },
          { name: 'subject' },
          { name: 'account', type: 'object', properties: object_definitions['account'] }
        ]
      end
    },

    common_with_disabled: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          { name: 'id', type: 'integer' },
          { name: 'nodeID' },
          { name: 'name' },
          { name: 'sourceID' },
          { name: 'disabled', type: 'boolean' },
          { name: 'account', type: 'object', properties: object_definitions['account'] }
        ]
      end
    },

    common_with_localized_name: {
      fields: lambda do |connection, config_fields, object_definitions|
        [
          { name: 'id', type: 'integer' },
          { name: 'nodeID' },
          { name: 'name' },
          { name: 'localized_name' },
          { name: 'account', type: 'object', properties: object_definitions['account'] }
        ]
      end
    },

    webhook_event: {
      fields: lambda do |connection, config_fields, object_definitions|
        case config_fields['event_selection']
        when 'automation_rule'
          [
            { name: 'webhook_id', type: 'integer' },
            { name: 'webhook_nodeID' },
            { name: 'account_id' },
            { name: 'account' },
            { name: 'custom_url' },
            { name: 'name' },
            { name: 'event' },
            { name: 'object_id', type: 'integer' },
            { name: 'object_nodeID' },
            { name: 'person_id', type: 'integer' },
            { name: 'person_nodeID' },
            { name: 'person_name' },
            { name: 'instance_name' },
            { name: 'data', type: 'array', of: 'object', properties: [
              { name: 'key' },
              { name: 'value' }
            ] },
            { name: 'payload', type: 'object', properties: object_definitions['webhook_payload_output'] }
          ]
        when /^out_of_office_period\./
          [
            { name: 'webhook_id', type: 'integer' },
            { name: 'webhook_nodeID' },
            { name: 'account_id' },
            { name: 'account' },
            { name: 'custom_url' },
            { name: 'name' },
            { name: 'event' },
            { name: 'object_id', type: 'integer' },
            { name: 'object_nodeID' },
            { name: 'person_id', type: 'integer' },
            { name: 'person_nodeID' },
            { name: 'person_name' },
            { name: 'instance_name' },
            { name: 'data', type: 'object', properties: [
              { name: 'callback' },
              { name: 'id', type: 'integer' },
              { name: 'nodeID' },
              { name: 'approval_delegate', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'created_at', type: 'date_time' },
              { name: 'effort_class', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'end_at', type: 'date_time' },
              { name: 'person', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'reason' },
              { name: 'source' },
              { name: 'sourceID' },
              { name: 'start_at', type: 'date_time' },
              { name: 'time_allocation', type: 'object', properties: object_definitions['common_with_localized_name'] },
              { name: 'updated_at', type: 'date_time' },
              { name: 'account', type: 'object', properties: object_definitions['account'] }
            ] }
          ]
        when /^time_entry\./
          [
            { name: 'webhook_id', type: 'integer' },
            { name: 'webhook_nodeID' },
            { name: 'account_id' },
            { name: 'account' },
            { name: 'custom_url' },
            { name: 'name' },
            { name: 'event' },
            { name: 'object_id', type: 'integer' },
            { name: 'object_nodeID' },
            { name: 'person_id', type: 'integer' },
            { name: 'person_nodeID' },
            { name: 'person_name' },
            { name: 'instance_name' },
            { name: 'data', type: 'object', properties: [
              { name: 'callback' },
              { name: 'id', type: 'integer' },
              { name: 'nodeID' },
              { name: 'connection', type: 'boolean' },
              { name: 'created_at', type: 'date_time' },
              { name: 'customer', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'date', type: 'date' },
              { name: 'deleted', type: 'boolean' },
              { name: 'description', type: 'boolean' },
              { name: 'effort_class', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'note_id', type: 'integer' },
              { name: 'note_nodeID' },
              { name: 'organization', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'person', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'problem', type: 'object', properties: object_definitions['common_with_subject'] },
              { name: 'project_task', type: 'object', properties: object_definitions['common_with_subject'] },
              { name: 'request', type: 'object', properties: object_definitions['common_with_subject'] },
              { name: 'service', type: 'object', properties: object_definitions['common_with_localized_name'] },
              { name: 'service_instance', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'started_at', type: 'date_time' },
              { name: 'task', type: 'object', properties: object_definitions['common_with_subject'] },
              { name: 'time_allocation', type: 'object', properties: object_definitions['common_with_name'] },
              { name: 'time_spent', type: 'integer' },
              { name: 'updated_at', type: 'date_time' },
              { name: 'account', type: 'object', properties: object_definitions['account'] }
            ] }
          ]
        else
          [
            { name: 'webhook_id', type: 'integer' },
            { name: 'webhook_nodeID' },
            { name: 'account_id' },
            { name: 'account' },
            { name: 'custom_url' },
            { name: 'name' },
            { name: 'event' },
            { name: 'object_id', type: 'integer' },
            { name: 'object_nodeID' },
            { name: 'person_id', type: 'integer' },
            { name: 'person_nodeID' },
            { name: 'person_name' },
            { name: 'instance_name' },
            { name: 'data', type: 'object', properties: [
              { name: 'callback' },
              { name: 'audit_line_id', type: 'integer' },
              { name: 'audit_line_nodeID' },
              { name: 'note_id', type: 'integer' },
              { name: 'note_nodeID' },
              { name: 'source' },
              { name: 'sourceID' },
              { name: 'status' },
              { name: 'previous_status' },
              { name: 'team', type: 'object', properties: object_definitions['common_with_disabled'] },
              { name: 'member', type: 'object', properties: object_definitions['common_with_disabled'] }
            ] }
          ]
        end
      end
    },

    webhook_payload_output: {
      fields: lambda do |connection, config_fields, object_definitions|
        next if config_fields['payload_output'].blank?

        parse_json(config_fields['payload_output'])
      end
    }
  },

  methods: {
    ###############################################################
    ### Methods required for 'custom_operation' action

    execute_custom_operation: lambda do |connection, input, eis, eos|
      # get variable input data
      variables = {}
      eis&.each do |field|
        field_name = field['name']
        next unless field_name.starts_with?('variable_')

        # strip for 9 characters
        variable_name = field_name[9..]

        variable_value = input["variable_#{variable_name}"]
        variables[variable_name] = variable_value
      end

      call(
        'run_gql',
        connection,
        input['query'],
        variables,
        input['operation_name'],
        input['account']
      )
    end,

    parse_graphql_type: lambda do |messages, type_string|
      m = type_string&.strip&.match(
        /(?<is_list>\[\s*)?(?<name>\w+)(?<required_1>!)?(?<end_list>\s*\])?(?<required_2>!)?/m
      )
      unless m.nil?
        {
          is_list: m['is_list'].present?,
          name: m['name'],
          is_optional: if m['is_list'].blank?
                         m['required_1'].blank?
                       else
                         m['required_2'].blank?
                       end
        }.compact
      end
    end,

    parse_graphql_variables: lambda do |report_problem, variables_string|
      variables = variables_string&.strip&.scan(
        /\$(\w+)\s*:\s*((\w|\[|\]|!)+)\s*(=\s*(.+?))?[,)]/
      )
      variables&.map do |variable|
        type_string = variable[1]
        type = call(
          'parse_graphql_type',
          report_problem,
          type_string
        )
        if type.nil?
          report_problem&.call("Could not parse type '#{type_string}'")
          next
        end
        {
          name: variable[0],
          type: type,
          default: variable[4]
        }.compact
      end&.compact
    end,

    parse_graphql_fields: lambda do |report_problem, fields_string|
      fields = fields_string&.scan(
        /(?<options>
           (?<fragmentRef>
             \.\.\.(?<fragmentName>\w+)
           )|
           (?<field>
             (?<fieldAlias>(?<fieldAliasName>\w+)\s*:\s*)?(?<fieldName>\w+)\s*
             (?<fieldArgs>\(.+?\))?\s*
             (?<fieldFields>{
               (?<fieldFieldsInner>[^{}]|\g<fieldFields>)*
             })?
           )|
           (?<inlineFragment>
            \.\.\.\s+on\s+(?<inlineFragmentType>\w+)\s*
            (?<inlineFragmentFields>{
              (?<inlineFragmentFieldsInner>[^{}]|\g<inlineFragmentFields>)*
            })
          )
         )/mx
      )
      fields&.map do |field|
        if field[6].present? # fieldName
          {
            name: field[6], # fieldName
            alias: field[5], # fieldAlias
            fields: call(
              'parse_graphql_fields',
              report_problem,
              field[8] # fieldFields
            )
          }.compact
        elsif field[2].present? # fragmentName
          {
            fragment_name: field[2] # fragmentName
          }.compact
        elsif field[11].present? # inlineFragmentType
          {
            fragment_type: field[11], # inlineFragmentType
            fields: call(
              'parse_graphql_fields',
              report_problem,
              field[12] # inlineFragmentFields
            )&.compact
          }
        else
          report_problem&.call 'Unexpacted field syntax'
        end
      end&.flatten(1)&.compact
    end,

    parse_graphql: lambda do |report_problem, query|
      # replace datapills by dummy values
      query = query&.gsub(/\#\{_\(.+\)\}/, 'datapill')

      # replace single-line comments
      query = query&.gsub(%r{//.*$}, '')
      query = query&.gsub(/#.*$/, '')

      # parse groups
      groups = query&.scan(/(?<group>[^{}]*(?<fields>{(?<inner>[^{}]|\g<fields>)*})?)/m)

      # parse documents
      documents = groups&.map do |group|
        group = group[0]
        m = group.match(/(?<type_and_Rest>
                           (?<operation_type>\w+)\s*
                           (?<name_and_rest>
                            (?<operation_name>\w+)\s*
                            (?<variables>\(.+?\))?\s*
                            )?
                         )?\s*
                         (?<fields>{.+})/mx)
        next if m.nil?

        operation_type = m['operation_type']
        next if operation_type == 'fragment'

        operation_type = 'query' if operation_type.blank?
        unless %w[query mutation].include? operation_type
          report_problem&.call 'Unsupported operation type, use query or mutation, and specify the operation name.'
          next
        end

        {
          operation_type: operation_type,
          operation_name: m['operation_name'],
          variables: call('parse_graphql_variables', report_problem, m['variables']),
          fields: call('parse_graphql_fields', report_problem, m['fields'])
        }.compact
      end&.compact

      # parse fragments
      fragments = groups&.map do |group|
        group = group[0]
        m = group.match(/fragment\s*
                         (?<fragment_name>\w+)\s+
                         on\s+
                         (?<fragment_type>\w+)\s+
                         {(?<fields>.+)}/mx)
        next if m.nil?

        {
          name: m['fragment_name'],
          type: m['fragment_type'],
          fields: call(
            'parse_graphql_fields',
            report_problem,
            m['fields']
          )
        }.compact
      end&.compact

      # return parsed query
      {
        documents: documents,
        fragments: fragments
      }
    end,

    create_custom_operation_output_fields: lambda do |connection, report_problem, operation|
      operation_type = call(
        'get_operation_type',
        connection,
        operation[:operation_type]
      )
      if operation_type.nil?
        report_problem&.call "Could not find #{operation[:operation_type]} operation type"
      end
      if operation_type.present?
        operation[:fields]&.map do |field|
          call(
            'create_custom_operation_output_field',
            connection,
            report_problem,
            operation,
            operation_type,
            field
          )
        end&.flatten(1)&.compact
      end
    end,

    create_custom_operation_output_field: lambda do |connection, report_problem, operation, parent_type, field|
      # field
      if field[:name].present?
        field_from_type = parent_type['fields']&.find do |f|
          f['name'] == field[:name]
        end
        report_problem&.call "Could not find field '#{field[:name]}'" if field_from_type.nil?
      end
      if field_from_type.present?
        # create workato schema field
        output_field = call(
          'create_output_field_for_type',
          connection,
          field_from_type['type']
        )
        call(
          'apply_field_name_and_label',
          output_field,
          nil,
          field[:alias] || field[:name]
        )

        # strip non_null and list to get the inner type
        field_type = call(
          'get_inner_type',
          field_from_type['type']
        )
        field_type = call(
          'get_schema_type',
          connection,
          report_problem,
          field_type['kind'],
          field_type['name']
        )

        # map fields to properties
        output_field[:properties] = field[:fields]&.map do |sub_field|
          call(
            'create_custom_operation_output_field',
            connection,
            report_problem,
            operation,
            field_type,
            sub_field
          )
        end&.flatten(1)&.compact

        output_field = output_field.compact
      elsif field[:name] == '__typename'
        output_field = {
          name: '__typename',
          type: :string,
          label: 'Type name'
        }
      end

      # fragment
      if field[:fragment_name].present?
        fragment = operation[:fragments]&.find do |f|
          f[:name] == field[:fragment_name]
        end
        if fragment.nil?
          report_problem&.call "Could not find fragment named '#{field[:fragment_name]}'"
        end
        fragment_type = call(
          'get_schema_type',
          connection,
          report_problem,
          'OBJECT',
          fragment[:type]
        )
        if fragment.present? && fragment_type.nil?
          report_problem&.call "Could not fragment type '#{fragment[:type]}'"
        end
      end
      if field[:fragment_type].present? # inline fragment
        fragment_type = call(
          'get_schema_type',
          connection,
          report_problem,
          'OBJECT',
          field[:fragment_type]
        )
        if fragment_type.nil?
          report_problem&.call "Could not inline fragment type '#{field[:fragment_type]}'"
        end
        fragment = field
      end
      if fragment.present? && fragment_type.present?
        output_field = fragment[:fields]&.map do |sub_field|
          call(
            'create_custom_operation_output_field',
            connection,
            report_problem,
            operation,
            fragment_type,
            sub_field
          )
        end&.flatten(1)&.compact
      end

      output_field
    end,

    create_custom_operation_variables_input_fields: lambda do |connection, report_problem, operation|
      operation[:variables]&.map do |variable|
        next if variable.nil?

        variable[:optional] = true unless variable.has_key?(:optional)
        type_name = variable.dig(:type, :name)

        variable_type = call(
          'get_schema_type',
          connection,
          report_problem,
          nil,
          type_name
        )
        if variable_type.nil?
          report_problem&.call "Could not get '#{type_name}' schema type."
          next
        end
        variable_field = call(
          'create_field_for_type',
          connection,
          report_problem,
          variable_type,
          0
        )
        call(
          'apply_field_name_and_label',
          variable_field,
          'variable',
          variable[:name]
        )
        default_value = variable[:default]
        variable_field[:hint] = "Defaults to #{default_value}" if default_value.present?
        is_optional = variable.dig(:type, :is_optional)
        is_optional = true if is_optional.nil?
        variable_field[:optional] = is_optional
        if variable.dig(:type, :is_list)
          variable_field[:of] = variable_field[:type]
          variable_field.delete(:control_type)
          variable_field[:type] = :array
        end
        variable_field
      end&.compact
    end,

    ###############################################################
    ### Methods shared across all actions

    get_error_message: lambda do |connection, response|
      message = nil

      # rubocop:disable Style/CaseLikeIf
      if response.is_a?(Hash)
        keys = %w[errors message]
        keys.each do |key|
          value = response[key]
          next if value.nil? || message.present?

          message = call('get_error_message', connection, value)
        end
      # rubocop:enable Style/CaseLikeIf
      elsif response.is_a?(Array)
        messages = response.map do |value|
          call('get_error_message', connection, value)
        end.compact
        message = messages.join("\n") if messages.present?
      elsif response.is_a?(String)
        value = response.strip
        message = value if value.present?
      end
      message
    end,

    # Perform GraphQL operation
    run_gql: lambda do |connection, document, variables, operation_name, account|
      account ||= connection['account']

      payload = {
        'query' => document,
        'operationName' => operation_name,
        'variables' => variables
      }.compact

      request = post('')
      request.headers('x-4me-Account': account)
      request = request.payload(payload)
      handle_errors = lambda do |response|
        error = call('get_error_message', connection, response)
        error(error) if error.present?
      end
      request = request.after_error_response('.*') do |code, body, header, message|
        content_type = header['content_type'] || ''
        if content_type.include?('application/json')
          response = workato.parse_json(body)
          handle_errors.call(response)
        end
        error("#{message}: #{body}")
      end
      # for some reason, 301 was not handles without 'follow_redirection' (AG)
      request.follow_redirection.after_response do |code, body, res_headers|
        handle_errors.call(body)
        result = body['data']
        result['rate_limit_headers'] = {
          'limit' => res_headers['x_ratelimit_limit'],
          'remaining' => res_headers['x_ratelimit_remaining'],
          'reset' => ('1970-01-01T00:00:00Z'.to_time + res_headers['x_ratelimit_reset'].to_i.seconds)
        }
        result
      end
    end,

    # Get the server's GraphQL schema. If the schema is not available,
    # it will be fetched from the server and cached in memory.
    get_schema: lambda do |connection|
      unless connection.has_key?('__schema')
        schema = call(
          'run_gql',
          connection,
          "{
            __schema {
              queryType {
                name
              }
              mutationType {
                name
              }
              types {
                kind
                name
                description
                fields {
                  name
                  description
                  args {
                    name
                    description
                    type {
                      ...typeReference
                    }
                    defaultValue
                  }
                  type {
                    ...typeReference
                  }
                  isDeprecated
                }
                inputFields {
                  name
                  description
                  type {
                    ...typeReference
                  }
                  defaultValue
                  isDeprecated
                }
                enumValues {
                  name
                  description
                  isDeprecated
                }
                possibleTypes {
                  ... typeReference
                }
              }
            }
          }

          fragment typeReference on __Type {
            name
            kind
            ofType {
              name
              kind
              ofType {
                name
                kind
                ofType {
                  name
                  kind
                  ofType {
                    name
                    kind
                  }
                }
              }
            }
          }
          ",
          nil,
          nil,
          connection['account']
        )
        connection['__schema'] = schema
      end
      connection['__schema']
    end,

    labelize: lambda do |name, deprecated|
      # replace all non-word characters with a space
      name = name&.to_s&.gsub(/\W|-|_/, ' ')
      name = name.gsub(/\s{2,}/, ' ')
      name = name.strip
      name = name.gsub(/([a-z])([A-Z])/, '\1 \2')
      name = name.gsub(/\b[A-Z][a-z]+/) { |word| word.downcase }
      name = 'ID' if name == 'id'
      name = name.sub(/ id$/, ' ID')
      name = name.sub(/^id /, 'ID ')
      name = name.gsub(/ id /, ' ID ')
      name = name.sub(/^\w/) { |word| word.upcase }
      name = "#{name} (deprecated)" if deprecated
      name
    end,

    # Get the GraphQL type for the given kind and name.
    get_schema_type: lambda do |connection, report_problem, kind, name|
      schema = call('get_schema', connection)
      types = schema.dig(
        '__schema',
        'types'
      )
      type = types.find do |t|
        t['name'] == name &&
          (kind.nil? || t['kind'] == kind)
      end
      if type.nil?
        if kind.nil?
          report_problem&.call "Could not find type '#{name}'"
        else
          report_problem&.call "Could not find #{kind} type '#{name}'"
        end
      end
      type
    end,

    create_field_for_type: lambda do |connection, report_problem, type, nesting_level|
      field = {
        optional: true
      }
      case type['kind']
      when 'NON_NULL'
        field = call(
          'create_field_for_type',
          connection,
          report_problem,
          type['ofType'],
          nesting_level
        )
        field[:optional] = false
      when 'SCALAR'
        case type['name']
        when 'Boolean'
          field[:type] = :boolean
          field[:control_type] = :checkbox
          field[:convert_input] = :boolean_conversion
          field = field.deep_merge(
            {
              type: :boolean,
              control_type: :checkbox,
              convert_input: :boolean_conversion,
              toggle_hint: 'Pick value',
              toggle_field: {
                type: :boolean,
                control_type: :text,
                convert_input: :boolean_conversion,
                toggle_hint: 'Provide value'
              }
            }
          )
        when 'Float', 'MonetaryAmount', 'Decimal'
          field[:type] = :number
          field[:control_type] = :number
          field[:convert_input] = :float_conversion
        when 'Int'
          field[:type] = :integer
          field[:control_type] = :integer
          field[:convert_input] = :integer_conversion
        when 'ISO8601Date'
          field = field.deep_merge(
            {
              type: :date,
              control_type: :date,
              convert_input: :date_conversion,
              toggle_hint: 'Pick date',
              toggle_field: {
                type: :date,
                control_type: :text,
                convert_input: :date_conversion,
                toggle_hint: 'Provide value'
              }
            }
          )
        when 'ISO8601DateTime', 'ISO8601Timestamp'
          field = field.deep_merge(
            {
              type: :date_time,
              control_type: :date_time,
              convert_input: :render_iso8601_timestamp,
              toggle_hint: 'Pick date and time',
              toggle_field: {
                type: :date_time,
                control_type: :text,
                convert_input: :render_iso8601_timestamp,
                toggle_hint: 'Provide value'
              }
            }
          )
        else # 'String', 'ID', ...
          field = field.merge(
            {
              type: :string,
              control_type: :text
            }
          )
        end
      when 'ENUM'
        enum_type = call(
          'get_schema_type',
          connection,
          report_problem,
          'ENUM',
          type['name']
        )
        pick_list = enum_type['enumValues'].map do |e|
          [
            call('labelize', e['name'], e['isDeprecated']),
            e['name']
          ]
        end
        field = field.merge(
          {
            type: :string,
            control_type: :select,
            pick_list: pick_list,
            toggle_hint: 'Select from list'
          }
        )
        call(
          'apply_field_description',
          connection,
          field,
          enum_type['description']
        )
        field[:toggle_field] = field.merge(
          {
            type: :string,
            control_type: :text,
            pick_list: nil,
            optional: nil,
            toggle_hint: 'Provide value'
          }
        ).compact
      when 'INPUT_OBJECT'
        field[:type] = :object
        input_object_type = call(
          'get_schema_type',
          connection,
          report_problem,
          'INPUT_OBJECT',
          type['name']
        )
        call(
          'apply_field_description',
          connection,
          field,
          input_object_type&.[]('description')
        )
        if nesting_level < 10
          input_fields = input_object_type&.[]('inputFields') || []
          field[:properties] = input_fields.map do |input_field|
            call(
              'create_field_for_input_field',
              connection,
              report_problem,
              input_field,
              nesting_level + 1
            )
          end
        end
      when 'LIST'
        field[:type] = :array
        item_field = call(
          'create_field_for_type',
          connection,
          report_problem,
          type['ofType'],
          nesting_level + 1
        )
        field[:of] = item_field[:type]
        field[:hint] = item_field[:hint]
        field[:properties] = item_field[:properties]
        field[:list_mode] = :static
      else
        error("Unsupported kind '#{type['kind']}'")
      end
      field[:toggle_field][:optional] = field[:optional] if field.has_key?(:toggle_field)
      field
    end,

    apply_field_name_and_label: lambda do |field, name_prefix, name|
      field[:name] = if name_prefix.blank?
                       name
                     else
                       "#{name_prefix}_#{name}"
                     end
      field[:label] = call('labelize', name, field['isDeprecated'])
      field[:sticky] = true
      toggle_field = field[:toggle_field]
      if toggle_field.present?
        toggle_field[:name] = field[:name]
        toggle_field[:label] = field[:label]
      end
      field
    end,

    apply_field_description: lambda do |connection, field, description|
      unless description.blank?
        field[:hint] = call(
          'format_field_hint',
          description
        )
      end
    end,

    get_operation_type: lambda do |connection, operation_type|
      schema = call('get_schema', connection)

      # get operation type name
      operation_type_name = schema.dig(
        '__schema',
        "#{operation_type}Type",
        'name'
      )

      # get operation type
      unless operation_type_name.blank?
        call(
          'get_schema_type',
          connection,
          nil,
          'OBJECT',
          operation_type_name
        )
      end
    end,

    create_field_for_input_field: lambda do |connection, report_problem, input_field, nesting_level|
      field = call(
        'create_field_for_type',
        connection,
        report_problem,
        input_field['type'],
        nesting_level
      )
      call(
        'apply_field_name_and_label',
        field,
        nil,
        input_field['name']
      )
      call(
        'apply_field_description',
        connection,
        field,
        input_field['description']
      )
      call(
        'apply_field_default_value',
        report_problem,
        field,
        input_field['defaultValue']
      )
      field
    end,

    format_field_hint: lambda do |description|
      if description.present?
        description = description.strip
        description = description.gsub('<p>', '<br>')
        description = description.gsub('</p>', '<br>')
        description = description.gsub(/\R/, '<br>')
        description = description.gsub('\\n', '<br>')
        description = description.gsub(/\*\*([^*]+)\*\*/, '<b>\1</b>')
        description = description.gsub(/^\s*\*\s/, '&#x2022; ')
        description = description.gsub(/`([^`]+)`/, '<b>\1</b>')
      end
      description
    end,

    # Check the type name excluding list and non-null
    get_inner_type: lambda do |type|
      case type['kind']
      when 'LIST', 'NON_NULL'
        call('get_inner_type', type['ofType'])
      else
        type
      end
    end,

    create_output_field_for_type: lambda do |connection, type|
      field = {}
      case type['kind']
      when 'NON_NULL'
        field = call(
          'create_output_field_for_type',
          connection,
          type['ofType']
        )
      when 'SCALAR'
        case type['name']
        when 'Boolean'
          field[:type] = :boolean
          field[:convert_output] = :boolean_conversion
        when 'Float', 'MonetaryAmount', 'Decimal'
          field[:type] = :number
          field[:convert_output] = :float_conversion
        when 'Int'
          field[:type] = :integer
          field[:convert_output] = :integer_conversion
        when 'ISO8601Date'
          field[:type] = :date
          field[:convert_output] = :date_conversion
        when 'ISO8601DateTime'
          field[:type] = :date_time
          field[:convert_output] = :date_time_conversion
        else # 'String', 'ID', ...
          field = field.merge(
            {
              type: :string
            }
          )
        end
      when 'ENUM'
        field = field.merge(
          {
            type: :string
          }
        )
      when 'OBJECT', 'INTERFACE', 'UNION'
        field[:type] = :object

      when 'LIST'
        field[:type] = :array
        item_field = call(
          'create_output_field_for_type',
          connection,
          type['ofType']
        )
        field[:of] = item_field[:type]
      else
        error("Unsupported kind '#{type['kind']}'")
      end
      field
    end,

    ###############################################################
    ### Methods required for 'query' and 'mutation' actions

    # Get all operation fields
    get_operation_fields: lambda do |connection, report_problem, operation_type|
      operation_schema_type = call(
        'get_operation_type',
        connection,
        operation_type
      )
      if operation_schema_type.nil?
        report_problem&.call "Could not find #{operation_type} operation type"
        []
      else
        operation_schema_type['fields'] || []
      end
    end,

    # Returns action input fields
    build_action_input_fields: lambda do |connection, input, operation_type|
      problems = []
      report_problem = ->(msg) { problems << msg }

      # get top-level fields
      operation_fields = call(
        'get_operation_fields',
        connection,
        nil,
        operation_type
      )

      # Build action's top-level object input pick-list
      pick_list = operation_fields.map do |field|
        name = field['name']
        label = call('labelize', name, field['isDeprecated'])
        name = "#{name}{}" if call('is_object_type', field['type'])
        [label, name]
      end

      # get operation-specific UI values
      case operation_type
      when 'query'
        label = 'Query'
        hint = 'Select records to retrieve'
      when 'mutation'
        label = 'Mutation'
        hint = 'Select operation to perform'
      else
        error("Unknown action name '#{operation_type}'")
      end

      # append example object name to hint
      if pick_list.present?
        object_label = pick_list.first[0]
        hint = "#{hint}, e.g. #{object_label.downcase}"
      end

      operation_input_field = {
        name: 'object',
        label: label,
        control_type: :select,
        pick_list: pick_list,
        extends_schema: true,
        schema_neutral: false,
        optional: false,
        hint: hint
      }

      fields = [operation_input_field]

      # get field for selected object
      operation_field_name = input['object']
      if operation_field_name.present?
        is_object = operation_field_name.ends_with?('{}')
        operation_field_name = operation_field_name[0..-3] if is_object
        operation_field = operation_fields.find do |field|
          field['name'] == operation_field_name
        end
      end

      # append additional fields
      if operation_field.present?
        operation_field_input_schema = call(
          'field_input_schema',
          connection,
          report_problem,
          operation_field,
          input
        )
        fields.concat operation_field_input_schema
      end

      ## Add 4me Account field
      fields.insert(0, {
                      name: 'account',
                      label: 'Account ID',
                      sticky: true,
                      default: connection['account'],
                      optional: false,
                      control_type: 'text',
                      hint: 'The 4me account identifier'
                    })

      error(problems.join(', ')) unless problems.empty?
      fields
    end,

    # Returns action output fields
    build_action_output_fields: lambda do |connection, input, operation_type|
      operation_field_name = input['object']
      if operation_field_name.present?
        is_object = operation_field_name.ends_with?('{}')
        operation_field_name = operation_field_name[0..-3] if is_object

        operation_fields = call(
          'get_operation_fields',
          connection,
          nil,
          operation_type
        )
        operation_field = operation_fields.find do |field|
          field['name'] == operation_field_name
        end
      end

      schema = []
      if operation_field.present?
        output_field = call(
          'create_action_output_field',
          connection,
          operation_field['type'],
          input
        )
        if output_field[:type] == :object
          schema = output_field[:properties]
        else
          call(
            'apply_field_name_and_label',
            output_field,
            nil,
            operation_field_name
          )
          schema << output_field
        end
        schema.insert(0, call('build_output_rate_limit_fields'))
      end
      schema
    end,

    build_output_rate_limit_fields: lambda do
      {
        name: 'rate_limit_headers',
        label: 'Rate limit',
        hint: 'Select objects to get additional information about',
        type: 'object',
        properties: [
          {
            name: 'limit',
            label: 'Limit',
            type: 'integer',
            hint: 'The maximum number of requests permitted to make in the current rate limit window.'
          },
          {
            name: 'remaining',
            label: 'Remaining',
            type: 'integer',
            hint: 'The number of requests remaining in the current rate limit window.'
          },
          {
            name: 'reset',
            label: 'Reset',
            type: 'timestamp',
            hint: 'The time at which the current rate limit window resets.'
          }
        ]
      }
    end,

    # Check if type has required fields
    is_non_null: lambda do |type|
      case type['kind']
      when 'NON_NULL'
        true
      when 'LIST'
        call('is_non_null', type['ofType'])
      else
        false
      end
    end,

    does_require_argument: lambda do |field|
      field['args']&.any? do |arg|
        call('is_non_null', arg['type'])
      end
    end,

    is_primitive_type: lambda do |type|
      type = type['ofType'] if type['kind'] == 'NON_NULL'
      type['kind'] == 'SCALAR' || type['kind'] == 'ENUM'
    end,

    is_object_type: lambda do |type|
      type = type['ofType'] if type['kind'] == 'NON_NULL'
      type['kind'] == 'OBJECT' || type['kind'] == 'INTERFACE'
    end,

    field_input_schema: lambda do |connection, report_problem, field, input|
      schema = []
      field['args']&.each do |field_arg|
        schema << call(
          'create_field_for_argument',
          connection,
          report_problem,
          field_arg
        )
      end

      if schema.present?
        properties = schema.first[:properties]
        property_item_id = properties.detect { |item| item[:name] == 'id' } unless properties.nil?
        properties.insert(0, properties.delete(property_item_id)) unless property_item_id.nil?
      end

      field_type = call(
        'get_inner_type',
        field['type']
      )
      field_type = call(
        'get_schema_type',
        connection,
        report_problem,
        field_type['kind'],
        field_type['name']
      )
      unless field_type.nil?
        schema.concat call(
          'create_input_fields_for_schema_type',
          connection,
          report_problem,
          field_type,
          input
        )
      end
      schema
    end,

    create_input_fields_for_schema_type: lambda do |connection, report_problem, schema_type, input|
      input_fields = []
      sub_fields = schema_type['fields'] || []

      # create sub-fields map for faster lookups
      sub_field_map = {}
      sub_fields.each do |sub_field|
        name = sub_field['name']
        sub_field_map[name] = sub_field
      end

      # Output fields
      primitive_fields = sub_fields.select do |sub_field|
        type = sub_field['type']
        call('is_primitive_type', type)
      end
      if primitive_fields.present?
        primitive_fields_pick_list = primitive_fields.map do |sub_field|
          [
            call('labelize', sub_field['name'], sub_field['isDeprecated']),
            sub_field['name']
          ]
        end
        input_fields << {
          name: 'primitive_fields',
          label: 'Fields to retrieve',
          hint: 'Select the fields that must be retrieved to improve performance. ' \
                'All fields are returned if left blank.',
          control_type: :multiselect,
          pick_list: primitive_fields_pick_list,
          extends_schema: true,
          schema_neutral: false,
          optional: true,
          sticky: true,
          delimiter: ','
        }

        selected_field_names = input&.[]('primitive_fields')&.split(',')
        unless selected_field_names.present?
          # default to non-required fields
          selected_field_names = primitive_fields.map do |sub_field|
            next if call('does_require_argument', sub_field)

            sub_field['name']
          end.compact
        end
        selected_field_names&.each do |field_name|
          output_field = sub_field_map[field_name]
          next unless output_field.present?

          field_schema = call(
            'field_input_schema',
            connection,
            report_problem,
            output_field,
            input&.[](field_name)
          )
          if field_schema.present?
            f = {
              'type' => :object,
              'properties' => field_schema
            }
            call(
              'apply_field_name_and_label',
              f,
              'field',
              field_name
            )
            input_fields << f
          end
        end
      end

      # Nested query
      nested_fields = sub_fields.reject do |sub_field|
        type = sub_field['type']
        call('is_primitive_type', type)
      end.compact

      if nested_fields.present?
        related_fields_pick_list = nested_fields.map do |sub_field|
          [
            call('labelize', sub_field['name'], sub_field['isDeprecated']),
            sub_field['name']
          ]
        end
        input_fields << {
          name: 'nested_fields',
          label: 'Sub queries',
          hint: 'Select related records to retrieve',
          control_type: :multiselect,
          pick_list: related_fields_pick_list,
          extends_schema: true,
          schema_neutral: false,
          optional: true,
          sticky: true,
          delimiter: ','
        }
        selected_field_names = input&.[]('nested_fields')&.split(',')
        selected_field_names&.each do |field_name|
          nested_field = sub_field_map[field_name]
          next unless nested_field.present?

          input_name = "field_#{field_name}"
          field_schema = call(
            'field_input_schema',
            connection,
            report_problem,
            nested_field,
            input&.[](input_name)
          )
          if field_schema.present?
            f = {
              'type' => :object,
              'properties' => field_schema
            }
            call(
              'apply_field_name_and_label',
              f,
              'field',
              field_name
            )
            call(
              'apply_field_description',
              connection,
              f,
              nested_field['description']
            )
            input_fields << f
          end
        end
      end

      # fragments
      possible_types = schema_type['possibleTypes']&.map do |possible_type|
        call(
          'get_schema_type',
          connection,
          report_problem,
          possible_type['kind'],
          possible_type['name']
        )
      end&.compact
      if possible_types.present?
        fragment_types_pick_list = possible_types.map do |possible_type|
          [
            call('labelize', possible_type['name'], possible_type['isDeprecated']),
            possible_type['name']
          ]
        end
        input_fields << {
          name: 'expected_fragment_types',
          label: 'Expected objects',
          hint: 'Select objects to get additional information about',
          control_type: :multiselect,
          pick_list: fragment_types_pick_list,
          extends_schema: true,
          schema_neutral: false,
          optional: true,
          sticky: true,
          delimiter: ','
        }

        # get user input
        selected_fragment_types = input&.[]('expected_fragment_types')&.split(',')
        selected_fragment_types&.each do |fragment_type_name|
          # get schema type for selected object
          schema_type = possible_types.find do |type|
            type['name'] == fragment_type_name
          end
          # skip if type name is not in list of possible types
          unless fragment_type_name.present?
            report_problem&.call(
              "Object '#{fragment_type_name}' not found in list of possible types"
            )
            next
          end
          # create fragment field
          fragment_field = {
            type: :object,
            optional: true
          }
          call(
            'apply_field_name_and_label',
            fragment_field,
            'fragment',
            fragment_type_name
          )
          fragment_field[:properties] = call(
            'create_input_fields_for_schema_type',
            connection,
            report_problem,
            schema_type,
            input[fragment_field[:name]]
          )
          # skip if empty
          next if fragment_field[:properties].empty?

          # add to list of fields
          input_fields << fragment_field
        end
      end
      input_fields
    end,

    create_action_output_field: lambda do |connection, field_type, input|
      # create workato schema field
      output_field = call(
        'create_output_field_for_type',
        connection,
        field_type
      )

      # strip non_null and list to get the inner type
      field_type = call(
        'get_inner_type',
        field_type
      )
      schema_type = call(
        'get_schema_type',
        connection,
        nil,
        field_type['kind'],
        field_type['name']
      )
      all_fields = schema_type&.[]('fields') || []
      possible_types = schema_type&.[]('possibleTypes') || []

      # create sub-fields map for faster lookups
      all_field_map = {}
      all_fields&.each do |sub_field|
        name = sub_field['name']
        all_field_map[name] = sub_field
      end

      # get output field names
      primitive_field_names = input&.[]('primitive_fields')&.split(',')
      unless primitive_field_names.present?
        # get default primitive fields
        primitive_fields = all_fields.select do |sub_field|
          type = sub_field['type']
          next unless call('is_primitive_type', type)

          # exclude from defaults if user input required
          next if call('does_require_argument', sub_field)

          true
        end
        primitive_field_names = primitive_fields.map do |sub_field|
          sub_field['name']
        end
      end

      # get nested field names
      nested_field_names = input&.[]('nested_fields')&.split(',')

      # map fields to properties
      properties = []
      selected_field_names = (primitive_field_names || []) +
                             (nested_field_names || [])
      selected_field_names.each do |field_name|
        sub_field = all_field_map[field_name]
        next unless sub_field.present?

        field = call(
          'create_action_output_field',
          connection,
          sub_field['type'],
          input&.[]("field_#{field_name}")
        )
        call(
          'apply_field_name_and_label',
          field,
          nil,
          field_name
        )
        properties << field
      end

      # add properties from fragments
      expected_fragment_type_names = input&.[]('expected_fragment_types')&.split(',')
      expected_fragment_type_names&.each do |fragment_type_name|
        fragment_type = possible_types.find do |type|
          type['name'] == fragment_type_name
        end
        next if fragment_type.nil?

        fragment_field = call(
          'create_action_output_field',
          connection,
          fragment_type,
          input&.[]("fragment_#{fragment_type_name}")
        )
        fragment_field[:properties]&.each do |field|
          properties << field if properties.none? { |p| p[:name] == field[:name] }
        end
      end

      # add type name field for interface and union types
      if possible_types.present?
        properties << {
          name: '__typename',
          type: :string,
          label: 'Type name'
        }
      end

      output_field[:properties] = properties if properties.present?
      output_field.compact
    end,

    create_field_for_argument: lambda do |connection, report_problem, argument|
      field = call(
        'create_field_for_type',
        connection,
        report_problem,
        argument['type'],
        0
      )
      call(
        'apply_field_name_and_label',
        field,
        'argument',
        argument['name']
      )
      call(
        'apply_field_description',
        connection,
        field,
        argument['description']
      )
      call(
        'apply_field_default_value',
        report_problem,
        field,
        argument['defaultValue']
      )
      field
    end,

    apply_field_default_value: lambda do |report_problem, field, default_value|
      hint = field[:hint]
      unless default_value.blank?
        if field[:optional] == false
          update_default_field = true
        else
          already_in_hint = hint&.downcase&.include?('default') &&
                            hint&.downcase&.include?(default_value)
          append_default_value = !already_in_hint
        end
      end
      if update_default_field
        formatted_value = case field[:type]
                          when :string, nil
                            default_value
                          when :integer, :timestamp
                            default_value.to_i
                          when :number
                            default_value.to_f
                          when :boolean
                            case default_value.to_s.downcase
                            when 'true', 't', '1', 'yes', 'y'
                              true
                            when 'false', 'f', '0', 'no', 'n'
                              false
                            end
                          when :datetime
                            if default_value.is_a?(String)
                              default_value.to_time
                            else
                              default_value
                            end
                          when :date
                            if default_value.is_a?(String)
                              default_value.to_date
                            else
                              default_value
                            end
                          when :object, :array
                            nil
                          else
                            report_problem&.call(
                              "Unexpected field type: #{field[:type]}"
                            )
                          end
        field[:default] = formatted_value if formatted_value.present?
      end
      if append_default_value
        formatted_value = case field[:type]
                          when :string, nil
                            default_value.to_s
                          when :integer
                            default_value.to_s
                          when :timestamp
                            default_value.to_s
                          when :number
                            default_value.to_s
                          when :boolean
                            case default_value.to_s.downcase
                            when 'true', 't', '1', 'yes', 'y', 'Yes'
                              'Yes'
                            when 'false', 'f', '0', 'no', 'n', 'No'
                              'No'
                            else
                              default_value.to_s
                            end
                          when :datetime
                            default_value.to_s
                          when :date
                            default_value.to_s
                          when :object, :array
                            default_value.to_s
                          else
                            report_problem&.call(
                              "Unexpected field type: #{field[:type]}"
                            )
                            default_value.to_s
                          end

        default_sentence = "Defaults to #{formatted_value}." if formatted_value.present?

        hint = if hint.present?
                 "#{hint} #{default_sentence}" if default_sentence.present?
               else
                 default_sentence
               end
        hint = "#{hint}." unless hint&.ends_with?('.')
        field[:hint] = hint
      end
    end,

    format_arg: lambda do |field, value|
      type = field['type']
      control_type = field['control_type']
      optional = field['optional']

      if value.is_a?(String) && value.binary?
        error("Sending binary data is currently not supported (field '#{field['label']}')")
      end

      # treat blank string for optional fields as nil
      value = nil if value == '' && optional

      unless value.nil? && optional
        value = field['default'] if value.nil?

        if %w[date_time date].include?(type) || (type == 'string' && control_type != 'select')
          value = value.to_json
        elsif type == 'array'
          value = Array.wrap(value)
          value = value.map do |v|
            f = field.merge(
              { 'type' => field['of'] }
            )
            call('format_arg', f, v)
          end&.join(', ')
          value = "[#{value}]"
        elsif type == 'object'
          kvs = field['properties']&.map do |f|
            n = f['name']
            v = value&.[](n)
            v = call('format_arg', f, v) unless v.nil?
            "#{n}: #{v}" unless v.nil?
          end
          kvs = kvs&.compact&.join(', ')
          value = "{#{kvs}}"
        elsif value.nil?
          value = 'null'
        else
          value = value.to_s
        end
        value
      end
    end,

    build_query_field: lambda do |field_name, input, eis, eos|
      args = eis&.map do |input_field|
        arg_name = input_field['name']
        next unless arg_name.starts_with?('argument_')

        value = input&.[](arg_name)
        arg_name = arg_name[9..]
        value = call('format_arg', input_field, value)
        next if value.nil?

        "#{arg_name}: #{value}"
      end
      args = args&.compact&.join(', ')
      args = "(#{args})" if args.present?
      sub_field_query = call(
        'build_query_field_list',
        input, eis, eos
      )
      "#{field_name}#{args} #{sub_field_query}"
    end,

    build_query_field_list: lambda do |input, eis, eos|
      fields = []
      eis&.each do |input_field|
        input_field_name = input_field['name']

        if input_field_name.starts_with?('root_')
          field_name = input_field_name[5..]
          field_input = input&.[](input_field_name)
          output_schema = eos&.find { |field| field['name'] == field_name }&.[]('properties')
          input_schema = input_field&.[]('properties')
          fields << call(
            'build_query_field',
            field_name,
            field_input,
            input_schema,
            output_schema
          )
        end

        if input_field_name == 'primitive_fields'
          primitive_field_names = input&.[](input_field_name)&.split(',')
          unless primitive_field_names.present?
            primitive_field_names = input_field['pick_list'].map do |pick_list_item|
              next unless eos&.find { |field| field['name'] == pick_list_item[1] }.present?

              pick_list_item[1]
            end
          end
          primitive_field_names.each do |primitive_field_name|
            field_input = input&.[]("field_#{primitive_field_name}")
            input_schema = eis&.find { |field| field['name'] == "field_#{primitive_field_name}" }&.[]('properties')
            output_schema = eos&.find { |field| field['name'] == primitive_field_name }&.[]('properties')
            fields << call(
              'build_query_field',
              primitive_field_name,
              field_input,
              input_schema,
              output_schema
            )
          end
        end

        if input_field_name == 'nested_fields'
          nested_field_names = input&.[](input_field_name)&.split(',')
          nested_field_names&.each do |nested_field_name|
            field_input = input&.[]("field_#{nested_field_name}")
            input_schema = eis&.find { |field| field['name'] == "field_#{nested_field_name}" }&.[]('properties')
            output_schema = eos&.find { |field| field['name'] == nested_field_name }&.[]('properties')
            fields << call(
              'build_query_field',
              nested_field_name,
              field_input,
              input_schema,
              output_schema
            )
          end
        end

        if input_field_name == 'expected_fragment_types'
          fragment_type_names = input&.[](input_field_name)&.split(',')
          fragment_type_names&.each do |fragment_type_name|
            field_input = input&.[]("fragment_#{fragment_type_name}")
            input_schema = eis&.find { |field| field['name'] == "fragment_#{fragment_type_name}" }&.[]('properties')
            fragment_fields = call(
              'build_query_field_list',
              field_input,
              input_schema,
              eos
            )
            fragment = "... on #{fragment_type_name} #{fragment_fields}"
            fields << fragment
          end
          fields << '__typename' if fragment_type_names.present?
        end
      end
      "{#{fields.join(' ')}}" if fields.present?
    end,

    build_full_query: lambda do |field_name, input, eis, eos, operation_type|
      is_object = field_name.ends_with?('{}')
      field_name = field_name[0..-3] if is_object
      if is_object
        eos = [
          'name' => field_name,
          'type' => :object,
          'properties' => eos
        ]
      end
      wrapped_input = {}
      wrapped_input["root_#{field_name}"] = input
      wrapped_eis = [
        {
          'name' => "root_#{field_name}",
          'type' => :object,
          'properties' => eis
        }
      ]
      field_list = call(
        'build_query_field_list',
        wrapped_input,
        wrapped_eis,
        eos
      )
      "#{operation_type} #{field_list}"
    end,

    action_execute: lambda do |connection, input, eis, eos, operation_type|
      field_name = input['object']
      unless field_name.blank?
        is_object = field_name.ends_with?('{}')

        query = call(
          'build_full_query',
          field_name,
          input,
          eis,
          eos,
          operation_type
        )
        result = call(
          'run_gql',
          connection,
          query,
          nil,
          nil,
          input['account']
        )
        if is_object
          field_name = field_name[0..-3]
          response = result[field_name]
          response['rate_limit_headers'] = result['rate_limit_headers']
          response
        else
          result
        end
      end
    end
  },

  triggers: {
    new_event: {
      title: 'Webhook event',
      subtitle: 'Triggers when a selected 4me object, e.g person, is created/updated, ' \
                'or on an automation rule notification.',
      description: lambda do |input, picklist_label|
        "New <span class='provider'>webhook</span> in <span class='provider'>4me</span>"
      end,

      help: lambda do |input, picklist_label, connection, webhook_base_url|
        <<~HTML
          Creates a job when an event is received from 4me. To set this webhook up,
          you will need to register the webhook below in 4me under "settings" => "webhooks". <br><br>
          <b>Webhook endpoint URL</b>
          <b class="tips__highlight">#{webhook_base_url}</b>
          More information on how to use 4me automation rules and webhooks can be found on the <a href="https://developer.4me.com/v1/workato_connector/" target="_blank">4me developer pages</a>.
        HTML
      end,

      config_fields:
        [
          {
            name: 'event_selection',
            label: 'Event',
            control_type: 'select',
            pick_list: 'webhook_events',
            optional: false,
            hint: 'Select a specific event.'
          },
          {
            name: 'webhook_identifier',
            label: 'Webhook identifier',
            control_type: 'plain-text',
            optional: false,
            hint: 'The webhook GraphQL identifier.'
          },
          {
            name: 'webhook_policy',
            label: 'JWT algorithm',
            control_type: 'select',
            pick_list: 'webhook_jwt',
            optional: false,
            hint: 'The webhook policy JWT algorithm.'
          },
          {
            ngIf: 'input.webhook_policy == "HS256" || input.webhook_policy == "HS384" || ' \
                  'input.webhook_policy == "HS512"',
            name: 'webhook_secret_hmac',
            label: 'HMAC secret',
            control_type: 'password',
            hint: 'The webhook policy HMAC secret.'
          },
          {
            ngIf: 'input.webhook_policy == "RS256" || input.webhook_policy == "RS384" || ' \
                  'input.webhook_policy == "RS512" || input.webhook_policy == "ES256" || ' \
                  'input.webhook_policy == "ES256" || input.webhook_policy == "ES384" || ' \
                  'input.webhook_policy == "ES512"',
            name: 'webhook_public_key',
            label: 'Public PEM key',
            control_type: 'text-area',
            hint: 'The webhook policy public key.'
          },
          {
            ngIf: 'input.event_selection == "automation_rule"',
            name: 'payload_output',
            extends_schema: true,
            schema_neutral: true,
            control_type: 'schema-designer',
            label: 'Payload schema',
            sticky: true,
            hint: 'The payload schema as defined in the "automation_rule" webhook event.'
          }
        ],

      webhook_key: lambda do |connection, input|
        input['webhook_identifier']
      end,

      webhook_notification: lambda do |
        input,
        payload,
        extended_input_schema,
        extended_output_schema,
        headers,
        params,
        connection,
        webhook_subscribe_output|

        jwt = payload&.[]('jwt')
        if jwt.present?
          data = case input['webhook_policy']
                 when /^HS/
                   workato.jwt_decode(jwt, input['webhook_secret_hmac'], input['webhook_policy'])['payload']['data']
                 when /^RS/
                   workato.jwt_decode(jwt, input['webhook_public_key'], input['webhook_policy'])['payload']['data']
                 when /^ES/
                   workato.jwt_decode(jwt, input['webhook_public_key'], input['webhook_policy'])['payload']['data']
                 end

          if data['webhook_nodeID'] == input['webhook_identifier'] &&
             (data['event'] == input['event_selection'] || data['event'] == 'webhook.verify')
            {
              webhook_id: data['webhook_id'],
              webhook_nodeID: data['webhook_nodeID'],
              account_id: data['account_id'],
              account: data['account'],
              custom_url: data['custom_url'],
              name: data['name'],
              event: data['event'],
              object_id: data['object_id'],
              object_nodeID: data['object_nodeID'],
              person_id: data['person_id'],
              person_nodeID: data['person_nodeID'],
              person_name: data['person_name'],
              instance_name: data['instance_name'],
              data: data['payload'].map { |key, value| { 'key' => key, 'value' => value } },
              payload: data['payload']
            }
          end
        end
      end,

      dedup: lambda do |record|
        "#{record['account_id']}_#{record['event']}_#{record['object_id']}_#{Time.now.to_f}"
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['webhook_event']
      end
    }
  },

  pick_lists: {
    webhook_jwt: lambda do |connection|
      [
        ['HMAC using SHA-256', 'HS256'],
        ['HMAC using SHA-384', 'HS384'],
        ['HMAC using SHA-512', 'HS512'],
        ['RSA using SHA-256', 'RS256'],
        ['RSA using SHA-384', 'RS384'],
        ['RSA using SHA-512', 'RS512'],
        ['ECDSA using P-256 and SHA256', 'ES256'],
        ['ECDSA using P-384 and SHA384', 'ES384'],
        ['ECDSA using P-521 and SHA512', 'ES512']
      ]
    end,

    webhook_events: lambda do |connection|
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
        ['Workflow create', 'workflow.create'],
        ['Workflow manager changed', 'workflow.manager-changed'],
        ['Workflow note added', 'workflow.note-added'],
        ['Workflow status changed', 'workflow.status-changed'],
        ['Workflow update', 'workflow.update']
      ]
    end
  }
}
# rubocop:enable Metrics/BlockLength
# rubocop:enable Style/IfUnlessModifier
# rubocop:enable Style/PreferredHashMethods
# rubocop:enable Style/SymbolProc
# rubocop:enable Lint/UnusedBlockArgument
