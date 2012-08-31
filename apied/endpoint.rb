#require 'active_model'
require 'heroku-api'
require 'json'
require 'redcarpet'
require 'sinatra/base'

class Endpoint

  class Server < Sinatra::Base

    private

    def data
      @data ||= if (body = request.body.read) && !body.empty?
        JSON.parse(request.body)
      else
        {}
      end
    end

    def heroku
      @heroku ||= begin
        # FIXME: hardcoded for simplicity
        request['Authorization'] ||= "Basic #{[':REDACTED'].pack('m').chomp}"
        api_key = request['Authorization'].split(' ', 2).last.unpack('m').first.split(':', 2).last
        heroku = Heroku::API.new(:api_key => api_key, :mock => true)
      end
    end

  end

end

class Endpoint

  def self.data
    @data ||= []
  end

  %w{delete get post put}.each do |method|
    class_eval <<-DEF, __FILE__, __LINE__ + 1
      def self.#{method}(path = nil, &block)
        data << {
          :accepts  => {},
          :method   => :#{method},
          :path     => '/' << [name.downcase, path].compact.join,
          :requires => {}
        }
        if block_given?
          instance_eval(&block)
        end
      end
    DEF
  end

  # dsl!

  def self.description(description)
    data.last[:description] = description
  end

  def self.accepts(name, description)
    data.last[:accepts][name] = description
  end

  def self.requires(name, description)
    data.last[:requires][name] = description
  end

  def self.response(&block)
    data.last[:response] = block
    Endpoint::Server.send(data.last[:method], data.last[:path], &block)
  end

  def self.sample(sample)
    data.last[:sample] = sample
  end

  # output

  def self.to_client
    client = ["class Client\n"]

    data.each do |datum|
      endpoint = name.downcase
      client << "  # Public: #{datum[:description]}"
      client << '  #'
      unless datum[:accepts].empty? && datum[:requires].empty?
        client << "  # options - hash of options for operation (default: {})"
        (datum[:accepts].merge(datum[:requires])).each do |key, value|
          client << "  #           :#{key} - #{value}"
        end
        client <<  '  #'
      end
      client << "  def #{datum[:method]}_#{endpoint}"
      unless !datum[:path].include?(':') && datum[:accepts].empty? && datum[:requires].empty?
        client.last << '('
      end
      if datum[:path].include?(':')
        segments = datum[:path].split('/').select {|segment| segment =~ /^:/}
        client.last << segments.map {|segment| segment[1..-1]}.join(', ')
        unless datum[:accepts].empty? && datum[:requires].empty?
          client.last << ', '
        end
      end
      unless datum[:accepts].empty? && datum[:requires].empty?
        client.last << 'options = {}'
      end
      unless !datum[:path].include?(':') && datum[:accepts].empty? && datum[:requires].empty?
        client.last << ')'
      end
      client << "    connection.request("
      unless datum[:accepts].empty? && datum[:requires].empty?
        client << "      :body   => options,"
      end
      client << "      :method => :#{datum[:method]},"
      path = []
      datum[:path].split('/').each do |segment|
        if segment[0..1] =~ /^:/
          path << ('#{' << segment[1..-1] << '}')
        else
          path << segment
        end
      end
      path = path.join('/')
      client << "      :path   => \"#{path}\""
      client << "    )"
      client << "  end\n"
    end

    client << "end\n"
    client.join("\n")
  end

  def self.to_html
    renderer = Redcarpet::Markdown.new(
      Redcarpet::Render::XHTML,
      :autolink => true,
      :fenced_code_blocks => true,
      :space_after_headers => true
    )
    renderer.render(to_md)
  end

  def self.to_md
    docs = ["# #{name}"]

    data.each do |datum|
      path = datum[:path]

      docs << "## #{datum[:method].upcase} #{path}\n"

      if datum[:description]
        docs << "*#{datum[:description]}*\n"
      end

      unless datum[:accepts].empty? && datum[:requires].empty?
        docs << "### Params\n"
      end
      [:accepts, :requires].each do |type|
        unless datum[type].empty?
          docs << "#### #{type.capitalize}\n"
          datum[type].each do |key, value|
            docs << "* `#{key}` #{value}"
          end
        end
      end
      unless datum[:accepts].empty? && datum[:requires].empty?
        docs << ""
      end

      if datum[:sample]
        docs << "### Sample Response\n"
        docs << "```"
        docs << datum[:sample].chomp
        docs << '```'
      end
    end

    docs.join("\n")
  end

end

require './apps'
