#
# Cookbook Name:: chef-logstash
# Recipe:: default
#
# Copyright (C) 2014 Wouter de Vos
#
# License: MIT
#

include_recipe "logstash::yumrepo" if platform_family? "rhel", "fedora"
include_recipe "logstash::apt"     if platform_family? "debian"

package "logstash"

directory "/etc/logstash" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

directory "/etc/logstash/conf.d" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

directory "/var/lib/monit" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

execute "remove-server-conf" do
  command %{
    if [ -e /etc/logstash/conf.d/server.conf ]; then
      rm /etc/logstash/conf.d/server.conf
    fi
  }
  not_if { node[:logstash][:server][:enabled] }
end

execute "remove-agent-conf" do
  command %{
    if [ -e /etc/logstash/conf.d/agent.conf ]; then
      rm /etc/logstash/conf.d/agent.conf
    fi
  }
  not_if { node[:logstash][:agent][:enabled] }
end

service "logstash" do
  case node["platform"]
    when "ubuntu"
      if node["platform_version"].to_f >= 14.04
        provider Chef::Provider::Service::Upstart
      end
  end
  supports :restart => true, :reload => false
  action :nothing
end

include_recipe "logstash::server" if node[:logstash][:server][:enabled]
include_recipe "logstash::agent"  if node[:logstash][:agent][:enabled]

