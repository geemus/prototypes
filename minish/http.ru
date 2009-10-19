require 'rubygems'
require 'rack'

module Minish

  def self.http(&block)
    Minish::HTTP.new(&block)
  end

  class HTTP

    attr_accessor :routes

    def initialize(&block)
      @path_stack = []
      @routes = {}
      if block_given?
        instance_eval(&block)
      end
      @finished = true
      self
    end

    def _(path, options = {}, &block)
      return if @finished
      options = { :method => 'GET' }.merge!(options)
      @path_stack.push(path)
      @routes[@path_stack.join('/').squeeze('/')] = block
      if block_given?
        instance_eval(&block)
      end
      @path_stack.pop
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new(@routes[request.path].call)
      response.finish
    end

  end

end

run Minish.http {
  _('/') {
    _('foo') { 'bar' }
    'hello world'
  }
}