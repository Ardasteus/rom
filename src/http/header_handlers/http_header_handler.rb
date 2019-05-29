module ROM
  module HTTP
    module HeaderHandlers
      class HTTPHeaderHandler
        include Component

        def initialize(itc)
          @itc = itc
        end

        def handle_header(hdr)

        end
      end
    end
  end
end
