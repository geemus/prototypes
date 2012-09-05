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
        JSON.parse(body)
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
    @data ||= {}
  end

  def self.current
    @current
  end

  def self.current=(new_current)
    @current = new_current
  end

  def self.plural
    @plural ||= name.downcase
  end

  def self.plural=(new_plural)
    @plural = new_plural
  end

  def self.singular
    @singular ||= name.downcase[0...-1]
  end

  def self.singular=(new_singular)
    @singular = new_singular
  end

  %w{delete get post put}.each do |method|
    class_eval <<-DEF, __FILE__, __LINE__ + 1
      def self.#{method}(path = nil, &block)
        full_path = '/' << [plural, path].compact.join
        Endpoint.current = ['#{method.upcase}', full_path].join(' ')
        Endpoint.data[Endpoint.current] = {
          :accepts    => {},
          :method     => :#{method},
          :path       => full_path
        }
        if block_given?
          instance_eval(&block)
        end
        Endpoint.current = nil
      end
    DEF
  end

  # dsl!

  def self.description(description)
    Endpoint.data[Endpoint.current][:description] = description
  end

  def self.accepts(name, description)
    Endpoint.data[Endpoint.current][:accepts][name.to_s] = description
  end

  def self.response(&block)
    accepts   = Endpoint.data[Endpoint.current][:accepts]
    validates = Endpoint.data[plural][:validates]
    Endpoint::Server.send(Endpoint.data[Endpoint.current][:method], Endpoint.data[Endpoint.current][:path]) do
      errors = []
      data.keys.each do |key|
        unless accepts.keys.include?(key)
          errors << "`#{key}` is not a recognized option."
        end
        validates[key].each do |validation|
          unless instance_eval(&validation[:block])
            errors << validation[:description]
          end
        end
      end
      if errors.empty?
        instance_eval(&block)
      else
        status(412)
        body({'errors' => errors}.to_json)
      end
    end
  end

  def self.sample(sample)
    Endpoint.data[Endpoint.current][:sample] = sample
  end

  def self.validates(name, description, &block)
    Endpoint.data[plural] ||= {}
    Endpoint.data[plural][:validates] ||= Hash.new {|hash, key| hash[key] = []}
    Endpoint.data[plural][:validates][name.to_s] << { :description => description, :block => block }
  end

  # output

  def self.to_client
    client = ["require 'json'\n", "class Client\n"]

    client << " class Errors < StandardError; end\n"

    client << '  def connection'
    client << "    @connection ||= begin"
    client << "      require('excon')"
    client << "      connection = Excon.new('http://localhost:9292')"
    client << '      def connection.request(params, &block)'
    client << '        response = super'
    client << '        response.body = JSON.parse(response.body) rescue response.body'
    client << '        response'
    client << '      end'
    client << '      connection'
    client << '    end'
    client << "  end\n"

    Endpoint.data.each do |key, datum|
      if datum.keys == [:validates]
        next
      end

      name = if datum[:method] == :get && !datum[:path].include?(':')
        plural
      else
        singular
      end

      endpoint_has_arguments = datum[:path].include?(':')
      endpoint_has_options = !datum[:accepts].empty?

      client << "  # Public: #{datum[:description]}"
      client << '  #'
      if endpoint_has_options
        client << "  # options - hash of options for operation (default: {})"
        keys = datum[:accepts].keys.sort
        longest_key = keys.map {|key| key.length}.max
        keys.each do |key|
          client << "  #           :#{key.ljust(longest_key)} - #{datum[:accepts][key]}"
        end
        client <<  '  #'
      end
      client << "  def #{datum[:method]}_#{name}"
      if endpoint_has_arguments || endpoint_has_options
        client.last << '('
      end
      if endpoint_has_arguments
        segments = datum[:path].split('/').select {|segment| segment =~ /^:/}
        client.last << segments.map {|segment| segment[1..-1]}.join(', ')
        if endpoint_has_options
          client.last << ', '
        end
      end
      if endpoint_has_options
        client.last << 'options={}'
      end
      if endpoint_has_arguments || endpoint_has_options
        client.last << ')'
      end

      if endpoint_has_options
        client << '    errors = []'
        client << '    options.keys.each do |key|'
        known_keys = datum[:accepts].keys
        client << "      unless %w{#{known_keys.join(' ')}}.include?(key.to_s)"
        client << '        errors << "`#{key}` is not a recognized option."'
        client << '      end'
        client << '    end'
        client << '    unless errors.empty?'
        client << '      raise Errors.new(["Request Errors:"].concat(errors).join("\n"))'
        client << '    end'
      end

      client << "    connection.request("
      if endpoint_has_options
        client << "      :body   => options.to_json,"
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
    docs = ["# #{name}\n"]

    endpoint, datum = Endpoint.data.detect {|key, value| value.keys == [:validates]}
    validations = datum[:validates].values.flatten
    unless validations.empty?
      docs << "## Validations\n"
      validations.each do |value|
        docs << "* #{value[:description]}"
      end
      docs << ""
    end

    Endpoint.data.each do |key, datum|
      if datum.keys == [:validates]
        next
      end
      path = datum[:path]

      docs << "## #{datum[:method].upcase} #{path}\n"

      if datum[:description]
        docs << "*#{datum[:description]}*\n"
      end

      unless datum[:accepts].empty?
        docs << "### Options"
        datum[:accepts].each do |key, value|
          docs << "* `#{key}` - #{value}"
        end
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
