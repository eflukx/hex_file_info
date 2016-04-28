class HexString < String
  def to_byte_array
    scan(/../).map { |h| h.to_i(16) }
  end

  def to_byte_string
    to_byte_array.pack('C*')
  end
end

class String
  def to_hex_string
    unpack("C*").to_hex_string
  end
end

class Array
  def to_hex_string
    HexString.new map { |c| sprintf "%02x", c }.join
  end
end