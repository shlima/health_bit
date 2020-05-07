# frozen_string_literal: true

require 'rack'
require 'health_bit/version'

module HealthBit
  DEFAULT_SUCCESS_TEXT = '%<count>d checks passed 🎉'
  DEFAULT_HEADERS = {
    'Content-Type' => 'text/plain;charset=utf-8',
    'Cache-Control' => 'private,max-age=0,must-revalidate,no-store'
  }.freeze
  DEFAULT_SUCCESS_CODE = 200
  DEFAULT_FAIL_CODE = 500

  autoload :Check, 'health_bit/check'
  autoload :CheckError, 'health_bit/check_error'

  extend self # rubocop:disable Style/ModuleFunction

  attr_writer :success_text, :success_code, :fail_code, :headers
  attr_accessor :show_backtrace

  def success_text
    format(@success_text || DEFAULT_SUCCESS_TEXT, count: checks.length)
  end

  def success_code
    @success_code || DEFAULT_SUCCESS_CODE
  end

  def fail_code
    @fail_code || DEFAULT_FAIL_CODE
  end

  def headers
    (@headers || DEFAULT_HEADERS).dup
  end

  def checks
    @checks ||= []
  end

  def configure
    yield(self)
  end

  # @return [self]
  def add(name, handler = nil, &block)
    raise ArgumentError, <<~MSG if handler && block
      Both <handler> and <block> were passed to the <#{name}> check
    MSG

    raise ArgumentError, <<~MSG unless handler || block
      Nor <handler> or <block> were passed to the <#{name}> check
    MSG

    checks.push(Check.new(name, handler || block))

    self
  end

  # @return [nil, CheckError]
  def check
    checks.each do |check|
      (exception = check.call).nil? ? next : (return exception)
    end

    nil
  end

  def rack(this = self)
    @rack ||= begin
      format = this.show_backtrace ? CheckError::FORMAT_FULL : CheckError::FORMAT_SHORT

      Rack::Builder.new do
        run ->(_env) do
          if (error = this.check)
            [this.fail_code, this.headers, [error.to_s(format)]]
          else
            [this.success_code, this.headers, [this.success_text]]
          end
        end
      end
    end
  end
end
