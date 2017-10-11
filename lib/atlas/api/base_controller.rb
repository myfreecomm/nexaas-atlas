# frozen_string_literal: true

module Atlas
  module API
    module BaseController
      extend Dry::Configurable
      include Atlas::Util::I18nScope
      include Atlas::Service::Util::ResponseHelpers
      setting :serializers_namespace

      def self.included(base)
        base.class_eval do
          include Hanami::Action
          extend Atlas::API::Context::DSL
        end
      end

      MODULE_SEPARATOR = '::'
      DEFAULT_ENCODING = 'utf-8'

      ERROR_CODE_TO_HTTP_STATUS = {
        Atlas::Enum::ErrorCodes::NONE => 200,
        Atlas::Enum::ErrorCodes::AUTHENTICATION_ERROR => 401,
        Atlas::Enum::ErrorCodes::PERMISSION_ERROR => 403,
        Enum::ErrorCodes::RESOURCE_NOT_FOUND => 404
      }.freeze

      def render(service_response)
        data = service_response.data
        code = service_response.code
        self.body = response_body(service_response).to_json
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        headers.merge!(response_headers(data))
      end

      # TODO: Kill render_* and use a `format` parameter to `render` + Renderers

      def render_stream(service_response)
        code = service_response.code
        self.body = response_stream_body(service_response)
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
      end

      def render_pdf(service_response)
        code = service_response.code
        return render(service_response) if code != Enum::ErrorCodes::NONE
        data = service_response.data.force_encoding(DEFAULT_ENCODING)
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        headers['Content-Type'] = 'application/pdf'
      end

      def render_xml(service_response)
        code = service_response.code
        return render(service_response) if code != Enum::ErrorCodes::NONE
        data = service_response.data
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        headers['Content-Type'] = 'application/xml'
      end

      def render_not_found
        message = I18n.t(:not_found, scope: 'atlas.api.base_controller')
        response_params = { key: :not_found, code: Enum::ErrorCodes::RESOURCE_NOT_FOUND, message: message }
        service_response = failure_response(response_params)
        self.body = service_response
        self.status = ERROR_CODE_TO_HTTP_STATUS[service_response.code] || 400
      end

      def render_zip(service_response)
        code = service_response.code
        return render(service_response) if code != Enum::ErrorCodes::NONE
        response_data = service_response.data
        self.body = response_data[:data]
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        headers['Content-Type'] = 'application/zip'
        headers['Content-Disposition'] = 'attachment; file_name="' + response_data[:file_name].to_s + '"'
      end

      private

      def response_stream_body(service_response)
        data = service_response.data
        return data if data.is_a?(Enumerator)
        headers.merge!(response_headers(data))
        Enumerator.new do |yielder|
          yielder << response_body(service_response).to_json
        end
      end

      def response_body(service_response)
        code = service_response.code
        service_data = service_response.data

        data = if service_data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
                 service_data.results
               elsif !service_response.success?
                 { code: code, message: service_response.message, errors: service_data }
               else
                 service_data
               end

        serializer_instance_to(data)
      end

      def serializer_instance_to(data)
        serializer_class_to(data).new(data)
      end

      def serializer_class_to(data)
        return API::Serializer::DummySerializer if data.blank? || data.is_a?(Hash)
        return serializer_class_to(data.first) if data.is_a?(Array)
        entity = data.class.name.split(MODULE_SEPARATOR).last
        BaseController.config.serializers_namespace.const_get("#{entity}Serializer".to_sym)
      rescue NameError
        API::Serializer::DummySerializer
      end

      def response_headers(data)
        base = { 'Content-Type' => 'application/json' }
        return base unless data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
        base.merge('Total' => data.total.to_s, 'Per-Page' => data.per_page.to_s)
      end
    end
  end
end
