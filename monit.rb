dep 'monit' do
    requires 'monit.managed'
end

dep 'monit.managed'


dep "autostart monit" do
  requires 'monit.managed'
  met? { "/etc/default/monit".to_fancypath.grep(/^[^#]*START=yes/) && File.exists?("/etc/init.d/monit") }
  meet {
    shell("sudo sed -i'' -e 's/^START=no$/START=yes/' '/etc/default/monit'")
    # remove existing monit startscripts
    # sudo("update-rc.d -f monit remove")
    # unless(File.exists?("/etc/init/monit.conf"))
    #   render_erb 'monit/monit.erb', :to => '/etc/init/monit.conf', :sudo => true
    # end
  }
end