pkg 'curl' do
  installs {
    via :apt, 'curl'
  }
end
pkg 'java' do
  installs { via :apt, 'sun-java6-jre' }
  provides 'java'
  after { shell "set -Ux JAVA_HOME /usr/lib/jvm/java-6-sun" }
end
pkg 'libssl headers' do
  installs { via :apt, 'libssl-dev' }
  provides []
end
pkg 'libxml' do
  installs { via :apt, 'libxml2-dev' }
  provides []
end
pkg 'mdns' do
  installs {
    via :apt, 'avahi-daemon'
  }
  provides []
end
pkg 'memcached'
pkg 'ncurses' do
  installs {
    via :apt, 'libncurses5-dev', 'libncursesw5-dev'
    via :macports, 'ncurses', 'ncursesw'
  }
  provides []
end
pkg 'nmap'
pkg 'oniguruma'
gem 'passenger' do
  installs 'passenger' => '>= 2.2.9'
  provides 'passenger-install-apache-module'
end
pkg 'pcre' do
  installs {
    via :brew, 'pcre'
    via :macports, 'pcre'
    via :apt, 'libpcre3-dev'
  }
  provides 'pcretest'
end
pkg 'rcconf' do
  installs { via :apt, 'rcconf' }
end
pkg 'screen'
pkg 'sshd' do
  installs {
    via :apt, 'openssh-server'
  }
end
pkg 'wget'
pkg 'zlib headers' do
  installs { via :apt, 'zlib1g-dev' }
  provides []
end
