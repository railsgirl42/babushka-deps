meta :rvm do
  def rvm args
    login_shell "rvm #{args}", :log => args['install']
  end

  def gem_path(gem_name, ruby_version)
    env_info(ruby_version).val_for('INSTALLATION DIRECTORY') + "/gems/" + gem_name + "-" + version(gem_name,ruby_version)
  end

  def ruby_wrapper_path(ruby_version)
    matches = env_info(ruby_version).val_for('RUBY EXECUTABLE').match(/[^\/]*(.*rvm\/)rubies\/([^\/]*)/)
    "#{matches[1]}wrappers/#{matches[2]}/ruby"
  end

  private

  def env_info(ruby_version)
    @_cached_env_info ||= rvm("use #{ruby_version} do gem env")
  end

  def version(gem_name,ruby_version)
    spec = YAML.parse(rvm("use #{ruby_version} do gem specification #{gem_name}"))
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
  requires 'ruby installed.rvm'.with(:default_ruby => default_ruby)
  met? { login_shell('ruby --version')["ruby #{default_ruby}"] }
  meet {
    rvm("use #{default_ruby} --default")
  }
end

dep 'bundler.rvm' do
  met? { rvm("gem list bundler")["bundler"] }
  meet { rvm("gem install bundler --no-rdoc --no-ri") }
end

dep 'passenger.rvm', :ruby_version do
  ruby_version.default("1.9.3")
  requires 'rvm installed', 'ruby installed.rvm'.with(:default_ruby => ruby_version)
  met? {
    rvm("use #{ruby_version} do gem list passenger")["passenger"]
  }
  meet {
    rvm("use #{ruby_version} do gem install passenger --no-rdoc --no-ri")
  }
end

dep 'passenger module installed.rvm', :ruby_version do
  ruby_version.default("1.9.3")
  requires 'rvm installed', 'apache setup', 'libcurl4-openssl-dev.managed', 'passenger.rvm'.with(:ruby_version => ruby_version)
  met? { File.exists?("#{gem_path("passenger",ruby_version)}/ext/apache2/mod_passenger.so") }
  meet { rvm("use #{ruby_version} do passenger-install-apache2-module -a") }
end

dep 'passenger apache configured.rvm', :ruby_version do
  ruby_version.default("1.9.3")
  requires 'passenger module installed.rvm'.with(:ruby_version => ruby_version)
  met? { File.exist?("/etc/apache2/mods-available/passenger.conf") }
  meet {
    load_str = "LoadModule passenger_module #{gem_path("passenger",ruby_version)}/ext/apache2/mod_passenger.so"
    str = [
      "PassengerRoot #{gem_path("passenger",ruby_version)}",
      "PassengerRuby #{ ruby_wrapper_path(ruby_version) }",
      "PassengerMaxPoolSize 2",
      "PassengerPoolIdleTime 0",
      "PassengerUseGlobalQueue on"
    ]
    append_to_file load_str, "/etc/apache2/mods-available/passenger.load", :sudo => true
    append_to_file str.join("\n "), "/etc/apache2/mods-available/passenger.conf", :sudo => true
    sudo("a2enmod passenger")
  }
end

