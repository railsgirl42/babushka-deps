

dep 'ruby' do
  setup {
    rubies = {
      'pkg' => "Install via #{Babushka::PkgHelper.for_system.manager_dep}",
      'ree' => "Build Ruby Enterprise Edition from source"
    }
    rubies['system'] = "Use the OS X-supplied version" if host.osx?
    chosen_ruby = sticky_var(:ruby_type,
      :message => "Which ruby would you like to use",
      :choice_descriptions => rubies,
      :default => (host.osx? ? 'system' : 'pkg')
    )
    requires "#{chosen_ruby} ruby"
  }
end

pkg 'pkg ruby' do
  installs {
    via :macports, 'ruby'
    via :brew, 'ruby'
    via :apt, %w[ruby irb ri rdoc ruby1.8-dev libopenssl-ruby]
  }
  provides %w[ruby irb ri rdoc]
end

dep 'system ruby', :for => :osx do
  met? {
    cmds_in_path? ['ruby', 'irb', 'ri', 'rdoc']
  }
end

src 'ree ruby' do
  source "http://rubyforge.org/frs/download.php/64475/ruby-enterprise-1.8.7-20090928.tar.gz"
  provides 'ruby', 'irb', 'ri', 'rdoc'
  met? {
    log_error "Not implemented yet - bug me on twitter (@ben_h) or even better, send me your dep :)"
    :fail
  }
end

pkg 'ruby 1.9' do
  installs {
    via :macports, 'ruby19'
    via :apt, %w[ruby1.9 irb1.9 ri1.9 rdoc1.9 ruby1.9-dev libopenssl-ruby1.9]
  }
  provides %w[ruby1.9 irb1.9 ri1.9 rdoc1.9]
end

