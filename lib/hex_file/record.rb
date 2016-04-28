module HexFile

  class InvalidRecord < StandardError;
  end

  class Record

    DATA = '00'
    END_OF_FILE = '01'
    EXTENDED_SEGMENT_ADDRESS = '02'
    START_SEGMENT_ADDRESS = '03'
    EXTENDED_LINEAR_ADDRESS = '04'
    START_LINEAR_ADDRESS = '05'

    attr_reader :type, :byte_count, :address, :data, :checksum

    def initialize(intel_hex_line)
      parse(intel_hex_line)
    end

    def data_size
      @byte_count
    end

    def ok?
      @checksum == calculate_checksum
    end

    def calculate_checksum
      256 - (@raw_hexstr[1...-2]
                 .to_byte_array
                 .inject(:+)
      ) & 0xff
    end

    def crc_data
      @address_hexstr.to_byte_string + data
    end

    def crc16
      Digest::CRC16.digest(self.crc_data).b
    end

    private

    def parse(intel_hex_line)
      @raw_hexstr = HexString.new intel_hex_line
      fail HexFile::InvalidRecord, 'Missing start code' unless @raw_hexstr.start_with?(':')

      @byte_count_hexstr = HexString.new intel_hex_line[1..2]
      @byte_count = @byte_count_hexstr.to_i(16)

      @address_hexstr = HexString.new intel_hex_line[3..6]
      @address = @address_hexstr.to_i(16)

      @type_hexstr = HexString.new intel_hex_line[7..8]
      @type = @type_hexstr.to_i(16)

      @data_hexstr = HexString.new intel_hex_line[9..-3]
      @data = @data_hexstr.to_byte_string

      @checksum_hexstr = HexString.new intel_hex_line[-2..-1]
      @checksum = @checksum_hexstr.to_i 16
    end


  end
end
