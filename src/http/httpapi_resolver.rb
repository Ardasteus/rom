module ROM
  class HTTPAPIResolver
    include Component
    def initialize(itc)
      @gateway = itc.lookup(ApiGateway).first
    end

    def resolve(http_request)
      request = http_request
      if request.method == "GET"
        path = request.path
        path[0] = ''
        path = path.split('/')
        #plan = @gateway.plan(path)
        path = path.map{|part| part.to_sym}
        plan = @gateway.plan(*path)
        type = plan.signature.return_type
      end
    end
  end
end