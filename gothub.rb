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
      }
    )
  end

  def request(params)
    connection.request(params).tap do |response|
      response.body = JSON.parse(response.body)
    end
  end

  def collection(name)
    class_eval <<-EOS, __FILE__, __LINE__
    EOS
  end

end

p GotHub.new.request(:method => :get, :path => '/api/v2/json/user/show')
