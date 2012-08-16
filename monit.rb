dep 'monit' do
    requires 'monit.managed'
end

dep 'monit.managed'


dep "autostart monit" do
  requires 'monit.managed'
  met? { !FancyPath.grep(/^[^#]*startup=0/, "/etc/default/monit") && File.exists?("/etc/init/monit.conf") }
  meet {
    shell("sed -i'' -e 's/^startup=0$/startup=1/' '/etc/default/monit'")
    # remove existing monit startscripts
    # sudo("update-rc.d -f monit remove")
    # unless(File.exists?("/etc/init/monit.conf"))
    #   render_erb 'monit/monit.erb', :to => '/etc/init/monit.conf', :sudo => true
    # end
  }
end