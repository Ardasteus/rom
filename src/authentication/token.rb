module ROM
  module Authentication
    Token = Struct.new(:type, :identity, :security_stamp, :expiry)
  end
end