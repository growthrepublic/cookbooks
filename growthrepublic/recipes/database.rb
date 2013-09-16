#
# Cookbook Name:: growthrepublic
# Recipe:: database
#
# Copyright 2013, Growth Republic Ltd.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "deploy"
include_recipe "database"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  postgresql_database deploy['database']['database'] do
    connection ({:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']})
    action :create
  end
end
