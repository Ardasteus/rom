# Created by Matyáš Pokorný on 2019-03-23.

module ROM
	# Represents a model of data
	# @note Dynamically generates getters and setters for defined properties (see {ROM::Model.property} and {ROM::Model.property!})
	# @see ROM::ModelProperty
	# @example
	# 	class MyModel < Model
	# 		property! :x, Integer
	# 		property :y, String, 'default'
	# 	end
	#
	# 	mdl = MyModel.new :x => 5
	# 	mdl.x # => 5
	# 	mdl.y # => 'default'
	# 	mdl.y = 'asdf'
	# 	mdl.y # => 'asdf'
	# 	mdl.x = 10
	# 	mdl.x # => 10
	# 	mdl.x = 'asdf' # => Exception: Attempt to assign value of type 'String' into 'Integer' on property 'x'!
	class Model
		# Gets properties of model
		# @return [Array<ROM::ModelProperty>] Properties of model
		def self.properties
			@props.values
		end
		
		# Instantiates the {ROM::Model} class
		# @param [Hash{Symbol => Object}] vals Values to initialize the model properties to
		def initialize(vals = {})
			@values = {}
			vals.each_pair do |key, value|
				self.class.assign(key, value)
				@values[key] = value
			end
			self.class.properties.each do |prop|
				next if @values.include?(prop.name.to_sym)
				raise("Property '#{prop.name}' is required!") if prop.required?
				@values[prop.name.to_sym] = prop.default
			end
		end
		
		# Gets value of a property
		# @param [Symbol] key Property to get the value of
		# @return [Object] Value of given property
		def [](key)
			raise("Undefined property '#{key}'!") unless @values.include?(key)
			return @values[key]
		end
		
		# Sets value of a property
		# @param [Symbol] key Property to set the value of
		# @param [Object] value Value to set the property to
		# @return [Object] Given value
		def []=(key, value)
			self.class.assign(key, value)
			@values[key] = value
		end
		
		# Converts model to string representation
		# @return [String] String representation of this model
		def to_s
			inspect
		end
		
		# Converts model to human readable string representation for debugging inspection
		# @return [String] String representation of this model
		def inspect
			str = "<#{self.class.name}"
			self.class.properties.each do |prop|
				str += " :#{prop.name}=#{@values[prop.name.to_sym].inspect}"
			end
			return str + '>'
		end
		
		# Preforms property value assignment checks including existence of property
		# @param [Symbol] key Property that is being assigned to
		# @param [Object] value Value that the property is being set to
		# @return [ROM::ModelProperty] Property that is being assigned to
		# @raise [Exception] When value cannot be assigned
		def self.assign(key, value)
			prop = self[key]
			raise("Undefined property '#{key}'!") if prop == nil
			assign_property(prop, value)
		end
		
		# Preforms property value assignment checks
		# @param [ROM::ModelProperty] prop Property that is being assigned to
		# @param [Object] value Value that the property is being set to
		# @return [ROM::ModelProperty] Property that is being assigned to
		# @raise [Exception] When value cannot be assigned
		def self.assign_property(prop, value)
			# TODO: Attribute value checking
			raise("Property '#{prop.name}' is required!") if prop.required? and nil == value
			raise("Attempt to assign value of type '#{value.class}' into '#{prop.type}' on property '#{prop.name}'!") unless prop.type.is(value)
			return prop
		end
		
		# Prepares the model class
		# @return [void]
		def self.prepare_model
			@props = {}
		end
		
		# Prepares all subclasses
		# @param [Class] sub Type of subclass
		# @return [void]
		def self.inherited(sub)
			sub.prepare_model
		end
		
		# Gets model property
		# @param [Symbol] prop Property to get
		# @return [ROM::ModelProperty] Property of model
		def self.[](prop)
			@props[prop]
		end
		
		# Defines a new property
		# @param [Symbol] nm Name of property
		# @param [Class, ROM::Type] type Type of property
		# @param [Object] df Default value of property
		# @param [Object] att Attributes of property
		# @return [ROM::ModelProperty] Resulting property
		# @raise [Exception] When property already exists
		def self.property(nm, type, df = nil, *att)
			raise("Property '#{nm}' already defined!") unless @props[nm] == nil
			raise('Model already instantiated!') if @inst
			prop       = ModelProperty.new(nm.to_s, type, false, df, *att)
			@props[nm] = prop
			
			define_method nm do
				return @values[nm]
			end
			
			define_method "#{prop.name}=".to_sym do |value|
				assign_property(prop, value)
				@values[nm] = value
			end
			
			return prop
		end
		
		# Defines a new required property
		# @param [Symbol] nm Name of property
		# @param [Class, ROM::Type] type Type of property
		# @param [Object] att Attributes of property
		# @return [ROM::ModelProperty] Resulting property
		# @raise [Exception] When property already exists
		def self.property!(nm, type, *att)
			raise("Property '#{nm}' already defined!") unless @props[nm] == nil
			raise('Model already instantiated!') if @inst
			prop       = ModelProperty.new(nm.to_s, type, true, nil, *att)
			@props[nm] = prop
			
			define_method nm do
				return @values[nm]
			end
			
			define_method "#{prop.name}=".to_sym do |value|
				assign_property(prop, value)
				@values[nm] = value
			end
			
			return prop
		end
		
		# Creates a type from given object
		# @param [Object] obj Object to convert
		# @param [Class, ROM::Types::Type, ROM::Model] type Target type
		# @return [ROM::Model, Object] Converted object
		# @raise [ROM::Model::ConversionException] When conversion failed
		def self.from_object(obj, type = self)
			if type.is_a?(Class) and type < Model
				if obj.is_a?(Hash)
					values = {}
					obj.each_pair do |key, value|
						prop = type[key.to_sym]
						raise ConversionException.new(obj, type, "Undeclared property '#{key}'!") if prop == nil
						values[key.to_sym] = from_object(value, prop.type)
					end
					begin
						return type.new(values)
					rescue Exception => ex
						raise ConversionException.new(obj, type, ex.message)
					end
				end
			elsif type.is_a?(Types::Type)
				case type
					when Types::Just
						return from_object(obj, type.type)
					when Types::Union
						type.types.each do |t|
							return from_object(obj, t) if t.is(obj)
						end
					when Types::Array
						return obj.collect { |i| from_object(i, type.type) } if obj.is_a?(Array)
					when Types::Hash
						if obj.is_a?(Hash)
							ret = {}
							obj.each_pair do |key, value|
								ret[from_object(key, type.key)] = from_object(value, type.value)
							end
							return ret
						end
				end
			else
				return obj if obj.is_a?(type)
			end
			raise ConversionException.new(obj, type, 'Types are invariant!')
		end
		
		# Represents a failure of conversion. When system failed to convert object to some type
		class ConversionException < Exception
			# Gets object that failed the conversion
			# @return [Object] Object that failed the conversion
			def object
				@obj
			end
			
			# Gets expected type
			# @return [ROM::Types::Type] Expected type
			def type
				@type
			end
			
			# Gets error of conversion
			# @return [String] Error of conversion
			def error
				@err
			end
			
			# Instantiates the {ROM::Model::ConversionException} class
			# @param [Object] obj Object that failed conversion
			# @param [Class, ROM::Types::Type] type Expected type
			# @param [String] err Conversion error
			def initialize(obj, type, err)
				@obj  = obj
				@type = Types::Type.to_t(type)
				@err  = err
				super("Failed to convert object '#{obj}' of type '#{obj.class}' to type '#{type}'!: #{err}")
			end
		end
	end
	
	# Represents a property of a model
	# @see ROM::Model
	class ModelProperty
		# Gets name of property
		# @return [String] Name of property
		def name
			@name
		end
		
		# Gets type of property
		# @return [ROM::Type] Type of property
		def type
			@type
		end
		
		# Gets attributes of property
		# @return [Array<Object>] Attributes of property
		def attributes
			@att
		end
		
		# Gets whether this property is required
		# @return [Boolean] True if property is required; false otherwise
		def required?
			@req
		end
		
		# Gets default value of property
		# @return [Object] Default value of property
		def default
			@def
		end
		
		# Instantiates the {ROM::ModelProperty} class
		# @param [String] nm Name of property
		# @param [Class, ROM::Type] type Type of property
		# @param [Boolean] req Determines whether property is required
		# @param [Object] df Default value of property
		# @param [Object] att Attributes of property
		def initialize(nm, type, req, df = nil, *att)
			@name = nm
			@type = Types::Type.to_t(type)
			@att  = (att == nil ? [] : att)
			@req  = req
			@def  = df
		end
		
		# Gets first attribute that matches block
		# @yield [item] Matching function
		# @yieldparam [Object] item Attribute to match against
		# @yieldreturn [Boolean] True if attribute matched; false otherwise
		# @return [Object] First attribute of given type; nil otherwise
		def attribute(&block)
			idx = @att.index(&block)
			return idx == nil ? nil : @att[idx]
		end
		
		# Searches for an attribute
		# @yield [item] Matching function
		# @yieldparam [Object] item Attribute to match against
		# @yieldreturn [Boolean] True if attribute matched; false otherwise
		# @return [Boolean] True if matching attribute was found; false otherwise
		def attribute?(&block)
			return @att.any(&block)
		end
	end
end