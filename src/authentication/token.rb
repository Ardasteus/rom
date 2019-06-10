module ROM
  module Authentication
    Token = Struct.new(:type, :identity, :generation, :expiry)
  end
end