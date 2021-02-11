# frozen_string_literal: true

module Atlas
  module Util
    module Sanitizer
      def sanitize(dirty_params)
        dirty_params.deep_symbolize_keys!
        dirty_params[:password] = '[FILTERED]' if dirty_params.has_key?(:password)
        dirty_params
      end
    end
  end
end
