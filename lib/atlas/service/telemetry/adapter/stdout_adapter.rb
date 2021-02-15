# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class StdoutAdapter
          attr_reader :filter

          def initialize(filter: nil)
            @filter = filter
          end

          def log(type, data)
            puts(
              type: type,
              data: filter_data(data)
            )

            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          end

          private

          def filter_data(data)
            return data unless filter || data[:params]

            filter.call(data)
          end
        end
      end
    end
  end
end
