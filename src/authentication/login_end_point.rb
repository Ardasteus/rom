module ROM
  module API
    class LoginResource < Resource
      def initialize(val)
        @val = val
      end

      action :value, String do
        hello(@val)
      end
    end

    class Login < StaticResource
      namespace :api, :login

      action :test, InstanceTest, :val! => String do |val|
        InstanceTest.new(val)
      end

      action :default, InstanceTest, DefaultAction[] do |name|
        InstanceTest.new(name)
      end
    end
  end
end