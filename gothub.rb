require 'rubygems'
require 'excon'
require 'json'
require 'base64'

class GotHub

  def connection
    @connection ||= Excon.new(
      "http://github.com",
      :headers => {
        'Authorization' => 'Basic ' << Base64.encode64("#{ENV['GITHUB_USERNAME']}/token:#{ENV['GITHUB_TOKEN']}").strip
      },
      :method => :get
    )
  end

  def request(params)
    connection.request(params).tap do |response|
      response.body = JSON.parse(response.body)
    end
  end

  def repos
    Repos.new(connection)
  end

end

class Model

  attr_accessor :attributes

  def initialize(new_attributes={})
    self.attributes = new_attributes
  end

  def self.one(request)
    self.new(request.body)
  end

  def self.many(request)
    request.body.map {|attributes| new(attributes)}
  end

end

class Collection

  def self.model(new_model=nil)
    unless new_model
      @model
    else
      @model = new_model
    end
  end

  def self.path(new_path=nil)
    unless new_path
      @path
    else
      @path = new_path
    end
  end

  attr_accessor :connection

  def initialize(connection)
    self.connection = connection
  end

  def request_many(options)
    self.class.model.many(request(options))
  end

  def request_one(options)
    self.class.model.one(request(options))
  end

  private

  def request(options)
    options[:path] = '' << self.class.path << options[:path]
    connection.request(options)
  end

end

class Repos < Collection

  class Repo < Model; end
  model(Repo)
  path('/api/v2/json/repos')

  def all(username)
    request_many(:path => "/show/#{username}")
  end

  def get(username, key)
    request_one(:path => "/show/#{username}/#{key}")
  end

  def search(query)
    request_many(:path => "/search/#{query}")
  end

end

gothub = GotHub.new
p gothub.repos.all('geemus')
p gothub.repos.get('geemus', 'fog')
