#!/usr/bin/env ruby

require 'rubygems'
require 'fog'
require 'formatador'

# 256MB RAM, 10GB Storage, Ubuntu 10.04 LTS (Lucid Lynx)
SERVER_ATTRIBUTES = {:flavor_id => 1, :image_id => 49}

# connect using rackspace credentials from default config in ~/.fog
compute = Fog::Compute.new(:provider => 'Rackspace')

Thread.main[:ip_addresses], Thread.main[:servers] = [], []

count = ARGV[0] && ARGV[0].to_i || 3
threads = []

Formatador.display_lines(['', "bootstrapping #{count} nodes...", ''])
count.times do |index|
  threads << Thread.new do
    server = compute.servers.bootstrap(SERVER_ATTRIBUTES)
    Thread.main[:servers] << server
    Thread.main[:ip_addresses] << server.addresses['public'].first
    server.ssh([
      %{wget http://downloads.basho.com/riak/riak-0.14/riak_0.14.0-1_amd64.deb},
      %{sudo dpkg -i riak_0.14.0-1_amd64.deb},
      %{sed -i "s/127.0.0.1/#{Thread.main[:ip_addresses].last}/" /etc/riak/app.config},
      %{sed -i "s/127.0.0.1/#{Thread.main[:ip_addresses].last}/" /etc/riak/vm.args},
      %{riak start}
    ])
  end
end
threads.each {|thread| thread.join}

Formatador.display_line("#{Thread.main[:ip_addresses].first} is joining cluster...")
Thread.main[:servers][1..-1].each do |server|
  Formatador.display_line("#{server.addresses['public'].first} is joining cluster...")
  server.ssh(%{riak-admin join riak@#{Thread.main[:ip_addresses].first}})
  server.wait_for { ssh(%{riak-admin ringready}).first.stdout =~ /TRUE/ }
end

Formatador.display_lines(['', "Riaked! ring_members => #{Thread.main[:ip_addresses].inspect}"])
Formatador.display_lines(['', "press enter to shutdown/cleanup"])
STDIN.getc

Thread.main[:servers].each {|server| server.destroy}