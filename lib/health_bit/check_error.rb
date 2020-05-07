# frozen_string_literal: true

module HealthBit
  class CheckError < StandardError
    FORMAT_FULL = :full
    FORMAT_SHORT = nil

    attr_reader :name, :exception

    def initialize(name, exception: nil)
      @name = name
      @exception = exception
    end

    # @return [String]
    def to_s(format = nil)
      io = StringIO.new
      io.puts "Check <#{name}> failed"

      case format
      when FORMAT_FULL
        describe_exception(io)
      end

      io.string
    end

    private

    def describe_exception(io)
      return if exception.nil?

      io.puts exception.inspect
      io.puts exception.backtrace.join("\n")
    end
  end
end
