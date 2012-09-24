require 'json'
require 'sinatra'
require 'heroku-api'

module DD

  module Errors
    class << self

      def not_found(resource = 'Resource')
        [
          404,
          {},
          "{'errors': ['#{resource} not found.']}"
        ]
      end

      def not_implemented
        [
          501,
          {},
          "{'errors': ['Interface not implemented.']}"
        ]
      end

    end
  end

  class Model

    def initialize(params, data)
      @params = params
      @data = data
    end

    def heroku
      @heroku ||= begin
        # FIXME: hardcoded for simplicity
        api_key = 'REDACTED'
        heroku = Heroku::API.new(:api_key => api_key, :mock => true)
      end
    end

    def data
      @data
    end

    def id
      @params[:id]
    end

    def options
      options_data = []
      %w{delete get head options patch post put}.each do |method|
        if methods.include?(:"#{method}")
          options_data << method.upcase
        end
      end
      options_data
    end

    def options_all
      options_data = []
      %w{delete get head options patch post put}.each do |method|
        if methods.include?(:"#{method}_all")
          options_data << method.upcase
        end
      end
      options_data
    end

    def method_missing(*args)
      DD::Errors.not_implemented
    end

  end

  class Server < Sinatra::Base
    def self.resources
      @resources ||= {
        'apps' => App
      }
    end

    def self.resources=(new_resources)
      @resources = new_resources
    end

    def current_resource
      @resource ||= begin
        if klass = self.class.resources[params[:resource]]
          data = begin
            body = request.body.read
            if body.empty?
              {}
            else
              JSON.parse(body)
            end
          rescue
            body
          end
          klass.new(params, data)
        else
          halt(DD::Errors.not_implemented)
        end
      end
    end

    delete('/:resource/:id') do
      unless data = current_resource.delete
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
        body(data.to_json)
      end
    end

    get('/:resource') do
      data = current_resource.get_all
      status(200)
      body(data.to_json)
    end

    get('/:resource/:id') do
      unless data = current_resource.get
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
        body(data.to_json)
      end
    end

    head('/:resource/:id') do
      unless data = current_resource.head
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
      end
    end

    options('/:resource') do
      status(204)
      headers['Allow'] = current_resource.options_all.join(' ')
    end

    options('/:resource/:id') do
      status(204)
      headers['Allow'] = current_resource.options.join(' ')
    end

    patch('/:resource/:id') do
      unless data = current_resource.patch
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
        body(data.to_json)
      end
    end

    post('/:resource') do
      unless data = current_resource.post
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
        body(data.to_json)
      end
    end

    put('/:resource/:id') do
      # TODO: ? should this support creation AND update? If so it should use 200/201.
      unless data = current_resource.put
        DD::Errors.not_found(current_resource.class.name.capitalize)
      else
        status(200)
        body(data.to_json)
      end
    end

    # TODO: ? override default 404 Not Found to use 503 Not Implemented
  end
end

class App < DD::Model

  def delete
    response = heroku.delete_app(id)
    response.body
  rescue
    nil
  end

  def get
    response = heroku.get_app(id)
    response.body
  rescue
    nil
  end

  def get_all
    response = heroku.get_apps
    response.body
  end

  def head
    response = heroku.head_app
    response.body
  rescue
    nil
  end

  def patch
    put
  end

  def post
    response = heroku.post_app(data)
    response.body
  rescue
    nil
  end

  def put
    response = heroku.put_app(id, data)
    response.body
  rescue
    nil
  end

end

# TODO: ? models raise errors (like NotFound) which are caught and reraised/displayed
# TODO: ? alternatively return data or nil to imply result (as per current)
# TODO: ? what about 200 vs 201 (and the like)
