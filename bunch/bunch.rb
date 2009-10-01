def bash(command)
  `bash -l -c '#{command}'`
end

def rvm(command)
  "source ~/.rvm/scripts/rvm && rvm #{command}"
end

raw_list = bash(rvm('list')).lstrip.squeeze("\n").gsub(' ','').split("\n")

header = nil
list = {}
for entry in raw_list
  entry.gsub!(/^=>/, '')
  if entry.match(/^.*:$/)
    header = entry
  elsif header != 'system:'
    data = entry.split(/\:|\(/).first.split('-')
    key = data.shift
    list[key] = "#{rvm('use')} #{key} -v #{data.join('-')}"
  else
    key = entry.split(/\:|\(/).first
    list[key] = "#{rvm('use')} system"
  end
end

for key, value in list
  print "\n#{key} #{'-' * (80 - key.size - 1)}\n\n"
  output = bash("#{value} && ruby #{ARGV}").split("\n")
  print output.map {|line| "  #{line}"}.join("\n")
  print "\n"
end
print "\n"
