require 'rubygems'
require 'fog'
require 'formatador'

FLAVOR_ID = 1 # 256MB RAM, 10GB Storage
IMAGE_ID = 49 # Ubuntu 10.04 LTS (Lucid Lynx)

count = ARGV[0] && ARGV[0].to_i || 3

# connect using rackspace credentials from default config in ~/.fog
compute = Fog::Compute.new(:provider => 'Rackspace')

Thread.main[:ip_addresses] = []
Thread.main[:servers] = []

Formatador.display_line('bootstrapping server(s)')

threads = []
count.times do
  threads << Thread.new do
    server = compute.servers.bootstrap(
      :flavor_id => FLAVOR_ID,
      :image_id => IMAGE_ID
    )
    Thread.main[:servers] << server
    Thread.main[:ip_addresses] << server.addresses['public'].first

    commands = [
      %{wget http://downloads.basho.com/riak/riak-0.14/riak_0.14.0-1_amd64.deb},
      %{sudo dpkg -i riak_0.14.0-1_amd64.deb},
      %{sed -i "s/127.0.0.1/#{Thread.main[:ip_addresses].last}/" /etc/riak/app.config},
      %{sed -i "s/127.0.0.1/#{Thread.main[:ip_addresses].last}/" /etc/riak/vm.args},
      %{riak start}
    ]

    unless Thread.main[:servers].length == 1
      commands << %{riak-admin join riak@#{Thread.main[:ip_addresses].first}}
    end

    server.ssh(commands)
  end
end  
threads.each {|thread| thread.join}

Formatador.display_line("ring_members => #{Thread.main[:ip_addresses].inspect}")

Formatador.display_line('press enter to shutdown/cleanup')
STDIN.getc

Thread.main[:servers].each do |server|
  server.destroy
end
