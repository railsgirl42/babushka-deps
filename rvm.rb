meta :rvm do
  def rvm args
    shell "/usr/local/rvm/bin/rvm #{args}", :log => args['install']
  end

  def gem_path(gem_name)
    env_info.val_for('INSTALLATION DIRECTORY') + "/gems/" + gem_name + "-" + version(gem_name)
  end

  def ruby_wrapper_path
    matches = env_info.val_for('RUBY EXECUTABLE').match(/[^\/]*(.*rvm\/)rubies\/([^\/]*)/)
    "#{matches[1]}wrappers/#{matches[2]}/ruby"
  end

  private

  def env_info
    @_cached_env_info ||= rvm('gem env')
  end

  def version(gem_name)
    spec = YAML.parse(rvm("gem specification #{gem_name}"))
    spec.select("/version/version")[0].value
  end
end

dep 'test.rvm' do
  met? { false }
  meet do
    # puts gem_path('passenger')
    # puts ruby_wrapper_path
    yaml = rvm('gem specification passenger')
    gem_spec = Gem::Specification.from_yaml(yaml)
    puts gem_spec.inspect
  end
end

dep 'rvm installed' do
  requires 'curl.bin', 'rvm requirements'
  met? { File.exist?("/usr/local/rvm") }
  meet do
    shell "curl -L https://get.rvm.io > /tmp/rvm-install-script"
    sudo "bash -s stable < /tmp/rvm-install-script"
    shell "rm /tmp/rvm-install-script"
  end
end

dep 'rvm requirements' do
  requires %w(build-essential.managed bison.managed openssl.managed libreadline6.managed libreadline6-dev.managed curl.bin zlib1g.managed libssl-dev.managed libyaml-dev.managed sqlite3.managed libxml.managed libxslt.managed)
end

dep 'rvm set group for user', :rvm_username do
  requires 'rvm installed'
  before { rvm_username.default(shell("whoami")) }
  met? { shell("groups #{rvm_username}").split(" ").include?("rvm") }
  meet { sudo("adduser #{rvm_username} rvm") }
end

dep 'ruby installed.rvm', :default_ruby do
  requires 'rvm installed'
  default_ruby.default("1.9.3")
  setup {
    unmeetable! "You must belong to the rvm group to install rubies." unless shell('groups').split(" ").include?("rvm")
  }
  met? { rvm("list").include?(default_ruby) }

  meet {
    rvm("install #{default_ruby}")
  }
end

dep 'setup default ruby.rvm', :default_ruby do
  requires 'ruby installed.rvm'
  met? { login_shell('ruby --version')["ruby #{default_ruby}"] }
  meet {
    rvm("use #{default_ruby} --default")
  }
end

dep 'bundler.rvm' do
  met? { rvm("gem list bundler")["bundler"] }
  meet { rvm("gem install bundler --no-rdoc --no-ri") }
end

dep 'passenger.rvm' do
  requires 'rvm installed'
  met? { rvm("gem list passenger")["passenger"] }
  meet { rvm("gem install passenger --no-rdoc --no-ri") }
end

dep 'passenger module installed.rvm' do
  requires 'rvm installed', 'apache setup' 'libcurl4-openssl-dev.managed', 'passenger.rvm'
  setup { set( :passenger_path, gem_path("passenger")) }
  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
  meet { login_shell("passenger-install-apache2-module -a") }
end

dep 'passenger apache configured.rvm', :passenger_path do
  requires 'passenger module installed.rvm'

  met? { File.exist?("/etc/apache2/mods-available/passenger.conf") }
  meet {
    load_str = "LoadModule passenger_module #{passenger_path}/ext/apache2/mod_passenger.so"
    str = [
      "PassengerRoot #{passenger_path}",
      "PassengerRuby #{ ruby_wrapper_path }",
      "PassengerMaxPoolSize 2",
      "PassengerPoolIdleTime 0",
      "PassengerUseGlobalQueue on"
    ]
    append_to_file load_str, "/etc/apache2/mods-available/passenger.load"
    append_to_file str.join("\n "), "/etc/apache2/mods-available/passenger.conf"
    shell("a2enmod passenger")
  }
end

