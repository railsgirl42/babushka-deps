dep 'passenger for apache' do
  requires 'passenger gem', 'passenger configured for apache'
end

gem 'passenger gem' do
  installs 'passenger'
  provides []
end

dep 'passenger configured for apache' do
  requires 'apache2'
  met? { File.exists? '/etc/apache2/conf.d/passenger' }
  meet {
    shell "passenger-install-apache2-module -a"
    vers = Babushka::GemHelper.has?('passenger')

    f = <<-CONF
# Autogenerated from 'passenger configured for apache' babushka dep
# DO NOT MODIFY
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-#{vers}/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-#{vers}
PassengerRuby /usr/bin/ruby1.8
CONF
    append_to_file f, '/etc/apache2/conf.d/passenger', :sudo => true
  }
end

