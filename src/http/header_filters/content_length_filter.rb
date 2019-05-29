module ROM
  module HTTP
    module Filters
      class ContentLengthFilter < HTTPHeaderFilter
        def initialize(itc)
          @itc = itc
          @required = true
          @header_to_filter = :content_length
        end

        def filter(hdr_value)
          return HTTPResponse.new(StatusCode::LENGTH_REQUIRED) if hdr_value == nil
        end
      end
    end
  end
end