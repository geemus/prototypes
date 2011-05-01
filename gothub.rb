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
    Model.many(request(options))
  end

  def request_one(options)
    Model.one(request(options))
  end

  private

  def request(options)
    options[:path] = '' << self.class.path << options[:path]
    connection.request(options)
  end

end

class Repos < Collection

  path('/api/v2/json/repos')

  def all(username)
    request_many(:path => "/show/#{username}")
  end

  def create(repo, data)
    query = { :name => repo }.merge(data)
    data.each do |key, value|
      query["values[#{key}]"] = value
    end
    request_one(:method => :post, :path => "/create", :query => query)
  end

  def delete(username, repo, delete_token=nil)
    query = {}
    if delete_token
      query[:delete_token] = delete_token
    end
    request_one(:method => :post, :path => "/delete/#{username}/#{repo}", :query => query)
  end

  def get(username, repo)
    request_one(:path => "/show/#{username}/#{repo}")
  end

  def search(query)
    request_many(:path => "/search/#{query}")
  end

  def unwatch(username, repo)
    request_one(:path => "/unwatch/#{username}/#{repo}")
  end

  def update(username, repo, data)
    query = {}
    data.each do |key, value|
      query["values[#{key}]"] = value
    end
    request_one(:method => :post, :path => "/show/#{username}/#{repo}", :query => query)
  end

  def watch(username, repo)
    request_one(:path => "/watch/#{username}/#{repo}")
  end

end

gothub = GotHub.new
p gothub.repos.get('geemus', 'fog')
