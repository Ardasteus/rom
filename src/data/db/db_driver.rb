# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	class DbDriver
		include Component

		DEFAULT_CONVENTIONS = {
			:table => Proc.new { |tab| tab },
			:column => Proc.new { |tab, col| col },
			:pk_column => Proc.new { |tab, col| col },
			:fk_column => Proc.new { |src, tgt, dest, sfx| "#{tgt}#{dest}#{(sfx == '' ? '' : "_#{sfx}")}" },
			:pk_key => Proc.new { |tab, cols| "pk_#{tab}_#{cols.join('_')}" },
			:fk_key => Proc.new { |src, tgt, from, to| "fk_#{src}_#{from}" },
			:index => Proc.new { |tab, uq, cols| "ix_#{tab}_#{cols.join('_')}" }
		}
		
		def name
			@name
		end
		
		def config_model
			@conf
		end
		
		def type(tp)
			raise('Method not implemented!')
		end
		
		def convention(nm, *args)
			DEFAULT_CONVENTIONS[nm]&.call(*args)
		end

		def select(from, where = nil, ord = [], vals = nil, limit = nil, offset = nil)

		end
		
		def initialize(itc, nm, conf)
			@name = nm
			@itc = itc
			@conf = conf
		end
		
		def connect(conf)
			raise('Method not implemented!')
		end
		
		def create(db, schema)
			raise('Method not implemented!')
		end
	end
end