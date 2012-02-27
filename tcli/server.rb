require("excon")
require("heroku-api")

class ValidationError < StandardError; end

Excon.stub(:host => "api.heroku.com", :method => :post, :path => "/") do |params|
  options = parse(params[:body])
  begin
    output = process(options)
    {
      :body     => output.join("\n"),
      :headers  => { "Content-Type" => "text/stdout" },
      :status   => 200
    }
  rescue ValidationError => error
    {
      :body     => error.message.join("\n"),
      :headers  => { "Content-Type" => "text/stderr" },
      :status   => 400
    }
  end
end

def parse(argv)
  options = {
    :arguments => [],
    :command   => nil,
    :flags     => {}
  }
  options[:command] = argv.shift
  flag = nil
  argv.each do |arg|
    if arg[0...1] == "-"
      flag = arg.gsub(/^-*/, "")
      options[:flags][flag] = nil
    elsif flag
      options[:flags][flag] = arg
      flag = nil
    else
      options[:arguments] << arg
    end
  end
  options
end

def process(options)
  heroku = Heroku::API.new(:api_key => "fake", :mock => true)
  output = []
  case options[:command]
  when "apps:create"
    validate({
      :flags => {
        :optional => ["name", "stack"]
      }
    }, options)
    data = heroku.post_app(options[:flags]).body
    output << "----> Created #{data['name']}, stack is #{data['stack']}."
    output << "      #{data['web_url']} | #{data['git_url']}"
  end
  output
end

def validate(expectations, options)
  expectations = {
    :arguments => [],
  }.merge(expectations)
  expectations[:flags] = {
    :optional => [],
    :required => []
  }.merge(expectations[:flags])

  output = []

  if expectations[:arguments].empty? && !options[:arguments].empty?
    output << "Unknown argument(s): #{options[:arguments]}."
  elsif !expectations[:arguments].empty? && options[:arguments].empty?
    output << "Missing expected argument(s) #{expectations[:arguments]}."
  end

  missing_flags = []
  expectations[:flags][:required].each do |required_flag|
    unless options[:flags].keys.include?(required_flag)
      missing_flags << required_flag
    end
  end
  unless missing_flags.empty?
    output << "Missing required flag(s): #{missing_flags}"
  end

  unknown_flags = []
  options[:flags].keys.each do |flag|
    unless expectations[:flags][:optional].include?(flag) || expectations[:flags][:required].include?(flag)
      unknown_flags << flag
    end
  end
  unless unknown_flags.empty?
    output << "Unknown flag(s): #{unknown_flags}"
  end

  unless output.empty?
    raise(ValidationError.new(output))
  end
end
