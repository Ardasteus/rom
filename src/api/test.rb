module ROM
	module API
		class InstanceTest < Resource
			def initialize(val)
				@val = val
			end
			
			action :value, String do
			  @val
			end
		end
		
		class Test < StaticResource
			namespace :api, :v1
			
			action :test, InstanceTest, :val => String do |val|
				InstanceTest.new(val)
			end
			
			action :default, String, DefaultAction[] do |name|
				"yo!: #{name}"
			end
		end
	end
end