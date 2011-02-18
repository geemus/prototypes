require 'rubygems'
require 'fog'
require 'json'

class Squeue

  def initialize(config = {})
    namespace = config.delete(:namespace)
    storage = Fog::Storage.new(config)
    @directory = storage.directories.get(namespace) || storage.directories.create(:key => namespace)
  end

  def pop
    if file = @directory.files.all.first
      data = JSON.parse(file.body)
      file.destroy
      data
    end
  end

  def push(data)
    key = Time.now.to_i.to_s << '.' << data[:id]
    @directory.files.create(:key  => key, :body => data.to_json)
    key
  end

end

if __FILE__ == $0
  squeue = Squeue.new(:namespace => 'squeue', :provider => 'AWS')
  p squeue.push(:id => 'foo', :do => :work)
  p squeue.pop
end
