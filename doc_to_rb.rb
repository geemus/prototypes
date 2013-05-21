require('json')

code = []
code << "require('excon')"
code << "require('json')"
code << "require('netrc')"
code << "class Hrk"
code << "  def self.connection"
code << "    @@connection ||= begin"
code << "      user, password = Netrc.read['api.heroku.com']"
code << "      Excon.new("
code << "        'https://api.heroku.com',"
code << "        :headers   => { 'Accept' => 'Accept: application/vnd.heroku+json; version=3' },"
code << "        :password  => password,"
code << "        :user      => user"
code << "      )"
code << "    end"
code << "  end"
code << "  def self.request(parameters={})"
code << "    JSON.parse(connection.request(parameters).body)"
code << "  end"
code << "end"

spec = JSON.parse(File.read('doc.json'))
spec['resources'].each do |resource, data|
  code << "class Hrk"
  code << "  def self.#{resource.downcase}"
  code << "    Hrk::#{resource}.new"
  code << "  end"
  code << "end"

  code << "class Hrk::#{resource.gsub(' ', '_')}"
  data['actions'].each do |action, params|
    args = []
    path = params['path'].gsub(/{([^}]*)}/) do |match|
      args << $1.gsub('-', '_')
      %|\#{#{args.last}}|
    end
    args << %|parameters={}|
    code << %|  def #{action.downcase.gsub(' ', '_')}(#{args.join(', ')})|
    code << %|    Hrk.request({|
    code << %|      :body     => parameters.to_json,|
    code << %|      :method   => :#{params['method'].downcase},|
    code << %|      :path     => "#{path}"|
    code << %|    })|
    code << %|  end|
  end
  code << "end"
end

File.open('hrk.rb', 'w') {|file| file.puts(code.join("\n"))}
