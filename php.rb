dep 'php server' do
  requires 'apache2.managed', 'libapache2-mod-php5.managed'
end

dep 'libapache2-mod-php5.managed' do
  provides []
  installs {
    via :apt, %w[libapache2-mod-php5 php5-mysql php5-gd]
  }
end

