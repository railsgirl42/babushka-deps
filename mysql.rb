
dep 'mysql access',:db_user, :db_host, :db_name, :db_password  do
  requires 'existing mysql db'.with(:db_name => db_name)
  db_user.default(:username)
  db_host.default('localhost')
  met? { mysql "use #{db_name}", db_user }
  meet { mysql %Q{GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'#{db_host}' IDENTIFIED BY '#{db_password}'} }
end

dep 'existing mysql db', :db_name do
  requires 'mysql configured'
  met? { mysql("SHOW DATABASES").split("\n")[1..-1].any? {|l| /\b#{db_name}\b/ =~ l } }
  meet { mysql "CREATE DATABASE #{db_name}" }
end

dep 'mysql configured' do
  requires 'mysql root password'
end

dep 'mysql root password',  :db_admin_password do
  requires 'mysql.managed'
  met? { raw_shell("echo '\q' | mysql -u root").stderr["Access denied for user 'root'@'localhost' (using password: NO)"] }
  meet {
    cmd = %Q{GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '#{db_admin_password}'}
    shell('mysql', '-u', 'root', :input => cmd.end_with(';'))
  }
end

dep 'mysql.managed' do
  installs {
    via :apt, %w[mysql-server libmysqlclient-dev]
  }
  provides 'mysql'
end

