module ROM
  module HTTP
    module Filters
      class HTTPHeaderFilter
        include Component

        def initiliaze(itc)
          @itc = itc
          @required = false
          @header_to_filter = :header
        end

        def accepts?(hdr)
          return @header_to_filter == hdr
        end

        def filter_header(hdr)

        end
      end
    end
  end
end