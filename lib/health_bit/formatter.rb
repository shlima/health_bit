# frozen_string_literal: true

require 'rack'
require 'health_bit/version'

module HealthBit
  # rubocop:disable Lint/UnusedMethodArgument
  class Formatter
    # @param error HealthBit::CheckError
    # @param env Hash
    # @param health_bit HealthBit
    def format_success(error, env, health_bit)
      health_bit.success_text
    end

    # @param error HealthBit::CheckError
    # @param env Hash
    # @param health_bit HealthBit
    def format_failure(error, env, health_bit)
      format = health_bit.show_backtrace ? CheckError::FORMAT_FULL : CheckError::FORMAT_SHORT
      error.to_s(format)
    end

    # @param env Hash
    # @param health_bit HealthBit
    def headers_success(env, health_bit)
      health_bit.headers
    end

    # @param error HealthBit::CheckError
    # @param env Hash
    # @param health_bit HealthBit
    def headers_failure(error, env, health_bit)
      health_bit.headers
    end

    # @param env Hash
    # @param health_bit HealthBit
    def code_success(env, health_bit)
      health_bit.success_code
    end

    # @param error HealthBit::CheckError
    # @param env Hash
    # @param health_bit HealthBit
    def code_failure(error, env, health_bit)
      health_bit.fail_code
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
