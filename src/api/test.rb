module ROM
	module API
		class Test < StaticResource
			namespace :api, :v1
			
			action :env do
				return ENV
			end
		end
	end
end