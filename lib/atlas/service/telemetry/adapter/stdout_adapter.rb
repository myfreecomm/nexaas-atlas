# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class StdoutAdapter
          include Atlas::Util::Sanitizer

          def log(type, data)
            puts(type: type, data: sanitize(data))
            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          end
        end
      end
    end
  end
end
