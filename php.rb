dep 'php server' do
  requires 'apache2', 'libapache2-mod-php5'
end

pkg 'libapache2-mod-php5' do
  provides []
  installs {
    via :apt, %w[libapache2-mod-php5 php5-mysql php5-gd]
  }
end

