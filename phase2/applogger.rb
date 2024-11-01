require 'logger'
require 'singleton'

class AppLogger
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)  # Log to standard output, or specify a file here
  end

  def method_missing(method, *args, &block)
    if @logger.respond_to?(method)
      @logger.send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    @logger.respond_to?(method) || super
  end
end
