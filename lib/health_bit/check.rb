# frozen_string_literal: true

module HealthBit
  class Check
    attr_reader :name, :handler

    def initialize(name, handler)
      @name = name
      @handler = handler
    end

    # @return [nil] if its ok
    # @return [CheckError] if not
    def call(env = {})
      arity = handler.is_a?(Proc) ? handler.arity : handler.method(:call).arity
      return if arity.abs == 1 ? handler.call(env) : handler.call

      raise('The check has returned a negative value')
    rescue Exception => e # rubocop:disable Lint/RescueException
      CheckError.new(name, exception: e)
    end
  end
end
