include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/database.yml" do
    source "database.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database], :environment => deploy[:rails_env])

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  template "#{deploy[:deploy_to]}/shared/config/memcached.yml" do
    source "memcached.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(
      :memcached => deploy[:memcached] || {},
      :environment => deploy[:rails_env]
    )

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  template "#{deploy[:deploy_to]}/shared/config/newrelic.yml" do
    source "newrelic.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:newrelic => deploy[:newrelic], :environment => deploy[:rails_env])

    notifies :run, "execute[restart Rails app #{application}]"

    Chef::Log.info 'Created new relic config file from Rails cookbook'

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  Chef::Log.info("Ensuring shared/assets directory for #{application} app...")

  directory "#{deploy[:deploy_to]}/shared/assets" do
    group deploy[:group]
    owner deploy[:user]
    mode 0775
    action :create
    recursive true
  end
end
