module ROM
	module API
		class Test < StaticResource
			namespace :api, :v1
			
			action :env, Types::Hash[String, String], :name => String do
				return ENV
			end
		end
	end
end