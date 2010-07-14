dep 'existing postgres db' do
  requires 'postgres gem', 'postgres access'
  met? {
    !shell("psql -l") {|shell|
      shell.stdout.split("\n").grep(/^\s*#{var :db_name}\s+\|/)
    }.empty?
  }
  meet {
    shell "createdb -O '#{var :username}' '#{var :db_name}'"
  }
end

gem 'postgres gem' do
  requires 'postgres software'
  installs 'pg'
  provides []
end

dep 'postgres access' do
  requires 'postgres software', 'user exists'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{var :username}\b/).empty? }
  meet { sudo "createuser -SdR #{var :username}", :as => 'postgres' }
end



pkg 'postgres software' do
  installs {
    via :macports, 'postgresql83-server'
    via :apt, %w[postgresql postgresql-client libpq-dev]
    via :brew, 'postgresql'
  }
  provides 'psql'
  after :on => :osx do
    sudo "mkdir -p /opt/local/var/db/postgresql83/defaultdb" and
    sudo "chown postgres:postgres /opt/local/var/db/postgresql83/defaultdb" and
    sudo "su postgres -c '/opt/local/lib/postgresql83/bin/initdb -D /opt/local/var/db/postgresql83/defaultdb'" and
    sudo "launchctl load -w /Library/LaunchDaemons/org.macports.postgresql83-server.plist"
  end
end
