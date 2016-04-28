module HexFile

  def self.read filename
    Info.new(File.open(filename, 'r'))
  end

  class Info

    def initialize(input)
      input = input.read if input.is_a? IO

      @record_types = []

      @records = input.each_line.map do |record_line|
        record = Record.new(record_line.strip)
        @record_types << record.type
        record
      end

      @record_types.uniq!
    end

    def binary_size type = :all
      records(type).map { |r| r.data_size }.reduce(:+) if type
    end

    def records type = :all
      if type == :all
        @records
      else
        @records.select { |r| r.type == type }
      end
    end

    def ok?
      records.select { |r| !r.ok? }.empty?
    end

    def format
      if has_linear_record_types?
        'I32HEX'
      elsif has_start_segment_record_type?
        'I16HEX'
      else
        'I8HEX'
      end
    end

    def record_types
      @record_types
    end

    def has_linear_record_types?
      record_types.include?(Record::EXTENDED_LINEAR_ADDRESS) ||
          record_types.include?(Record::START_LINEAR_ADDRESS)
    end

    def has_start_segment_record_type?
      record_types.include?(Record::START_SEGMENT_ADDRESS)
    end

    def to_s
      [
          "#{self.class}:",
          "format         #{format}",
          record_types.map { |t| "records/lines (type: #{t}) #{records(t).count}" },
          record_types.map { |t| "binary size   (type: #{t}) #{binary_size(t)}" },
          "checksums      #{ok? ? 'ok' : 'FAILED'}"
      ].join "\n"
    end

  end
end
