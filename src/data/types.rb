module ROM
	# Contains classes for type annotations
	module Types
		# Represents a symbol type
		# @abstract
		class Type
			# Decides whether given value is of this type
			# @param [Object] x Value to test
			# @return [Boolean] True if given value is of this type; false otherwise
			# @abstract
			def is(x)
				raise('Method not implemented!')
			end
			
			# Validates whether given type can be assigned to this type
			# @param [Class, Type] klass Class or type to check
			# @return [Bool] True if class can be assigned to this type; false otherwise
			# @abstract
			def accepts(klass)
				raise('Method not implemented!')
			end
			
			# Ensures given value is a type
			# @param [Class, ROM::Types::Type] x Value to convert to type
			# @return [ROM::Types::Type] Converted type
			# @raise [Exception] When given value is neither a class nor a type
			def self.to_t(x)
				return x if x.is_a?(Type)
				return Just[x] if x.is_a?(Class)
				raise('Given value is neither class nor type!')
			end
			
			def <=(other)
				Type.to_t(other).accepts(self)
			end
		end
		
		class Void < Type
			def is(x)
				false
			end
			
			def accepts(klass)
				klass = Type.to_t(klass)
				
				klass.is_a?(Just) ? klass.type == Void : false
			end
			
			def to_s
				'void'
			end
			
			def self.[]
				self.new
			end
		end
		
		# Represents one specific type
		class Just < Type
			# Gets the underlying type
			# @return [Class] Underlying type
			def type
				@type
			end
			
			# Instantiates the {ROM::Types::Just} class
			# @param [Class] type Class of type
			def initialize(type)
				@type = type
			end
			
			# Decides whether given value is of the underlying type
			# @param [Object] x Value to test
			# @return [Boolean] True if given value is of this type; false otherwise
			def is(x)
				x.is_a?(@type)
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				@type.to_s
			end
			
			# Validates whether given type can be assigned to the given type
			# @param [Class, Type] klass Class or type to check
			# @return [Bool] True if class can be assigned to the given type; false otherwise
			def accepts(klass)
				case klass
					when Just
						(klass.type <= @type) or false
					when Type
						klass.accepts(@type)
					else
						(klass <= @type) or false
				end
			end
			
			# Instantiates the {ROM::Types::Just} class
			# @param [Class] type Class of type
			# @return [ROM::Types::Just] New instance
			def self.[](type)
				return self.new(type)
			end
		end
		
		# Represents union of multiple types
		class Union < Type
			# Gets list of types in union
			# @return [Array<ROM::Types::Type>] List of types in union
			def types
				@types
			end
			
			# Validates whether given type can be assigned to any of the given types
			# @param [Class, Type] klass Class or type to check
			# @return [Bool] True if class can be assigned to any of the given types; false otherwise
			def accepts(klass)
				if klass.is_a?(Union)
					return klass.types.all? { |i| @types.any? { |j| j.accepts(i) } }
				else
					return @types.any? { |i| i.accepts(klass) }
				end
			end
			
			# Instantiates the {ROM::Types::Union} class
			# @param [Class, ROM::Types::Type] types List of types
			# @raise [Exception] When given list is nil or empty
			def initialize(*types)
				raise('No types given!') if types == nil or types.length == 0
				@types = types.collect { |i| Type.to_t(i) }
			end
			
			# Decides whether given value is of at least one of the union types
			# @param [Object] x Value to test
			# @return [Boolean] True if given value is of this type; false otherwise
			def is(x)
				@types.each do |i|
					return true if i.is(x)
				end
				return false
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				"[#{@types.collect(&:to_i).join(', ')}]"
			end
			
			# Instantiates the {ROM::Types::Union} class
			# @param [Class, ROM::Types::Type] types List of types
			# @return [ROM::Types::Union] New instance
			# @raise [Exception] When given list is nil or empty
			def self.[](*types)
				return self.new(*types)
			end
		end
		
		# Represents a type of an array of uniformly typed elements
		class Array < Type
			# Gets type of elements
			# @return [ROM::Types::Type] Type of elements
			def type
				@type
			end
			
			# Validates whether given type can be assigned to this type
			# @param [Class, Type] klass Type to check
			# @return [Bool] True if class can be assigned to this type; false otherwise
			def accepts(klass)
				klass.is_a?(Types::Array) and @type.accepts(klass.type)
			end
			
			# Instantiates the {ROM::Types::Array} class
			# @param [Class, ROM::Types::Type] type Type of elements
			def initialize(type)
				@type = Type.to_t(type)
			end
			
			# Decides whether given value is of type array, and that every element is of the same correct type
			# @param [Object] x Value to test
			# @return [Boolean] True if given value is of this type; false otherwise
			def is(x)
				(x.is_a?(::Array) and (x.index { |i| !@type.is(i) } == nil))
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				"Array<#{@type}>"
			end
			
			# Instantiates the {ROM::Types::Array} class
			# @param [Class, ROM::Types::Type] type Type of elements
			# @return [ROM::Types::Array] New instance
			def self.[](type)
				return self.new(type)
			end
		end
		
		# Represents a type of a map of uniformly typed key-value pairs
		class Hash < Type
			# Gets type of keys
			# @return [ROM::Types::Type] Type of keys
			def key
				@key
			end
			
			# Gets type of values
			# @return [ROM::Types::Type] Type of values
			def value
				@value
			end
			
			# Validates whether given type can be assigned to this type
			# @param [Class, Type] klass Type to check
			# @return [Bool] True if class can be assigned to this type; false otherwise
			def accepts(klass)
				klass.is_a?(Types::Hash) and @key.accepts(klass.key) and @value.accepts(klass.value)
			end
			
			# Instantiates the {ROM::Types::Map} class
			# @param [Class, ROM::Types::Type] key Type of keys
			# @param [Class, ROM::Types::Type] value Type of values
			def initialize(key, value)
				@key = Type.to_t(key)
				@value = Type.to_t(value)
			end
			
			# Decides whether given value is of type hash, and that every pair is of the same correct type
			# @param [Object] x Value to test
			# @return [Boolean] True if given value is of this type; false otherwise
			def is(x)
				return false unless x.is_a?(::Hash)
				x.each_pair do |k, v|
					return false unless key.is(k) and value.is(v)
				end
				return true
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				"Hash{#{@key} => #{@value}}"
			end
			
			# Instantiates the {ROM::Types::Map} class
			# @param [Class, ROM::Types::Type] key Type of keys
			# @param [Class, ROM::Types::Type] value Type of values
			# @return [ROM::Types::Hash] New instance
			def self.[](key, value)
				return self.new(key, value)
			end
		end
		
		# Represents a boolean type (a union between TrueClass and FalseClass)
		class Boolean < Union
			# Instantiates the {ROM::Types::Boolean} class
			def initialize
				super(::TrueClass, ::FalseClass)
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				"Boolean"
			end
			
			# Instantiates the {ROM::Types::Boolean} class
			def self.[]
				return self.new
			end
		end
		
		# Represents a type that can be null (union between a type and NilClass)
		class Maybe < Union
			# Instantiates the {ROM::Types::Maybe} class
			# @param [Class, ROM::Types::Type] type Underlying type
			def initialize(type)
				super(type, NilClass)
			end
			
			# Converts type to string representation
			# @return [String] String representation of this type
			def to_s
				"#{@type}?"
			end
			
			# Instantiates the {ROM::Types::Maybe} class
			# @param [Class, ROM::Types::Type] type Underlying type
			# @return [ROM::Types::Maybe]
			def self.[](type)
				return self.new(type)
			end
		end
	end
	
	include Types
end