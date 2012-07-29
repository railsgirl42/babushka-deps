dep 'passwordless sudo', :username do
  setup {
    unmeetable! "This dep must be run as root." unless shell('whoami') == 'root'
  }
  met? {
    shell 'sudo -k', :as => username # expire an existing cached password
    shell? 'sudo -n true', :as => username
  }
  meet {
    shell "echo '#{username} ALL=(ALL) NOPASSWD: ALL' >> /tmp/#{username}"
    shell "chmod 440 /tmp/#{username}"
    shell "mv /tmp/#{username} /etc/sudoers.d/#{username}"
  }
end

dep 'passwordless sudo removed' do
  setup {
    unmeetable! "This dep must be run as root." unless shell('whoami') == 'root'
  }
  met? {
    raw_shell('grep NOPASSWD /etc/sudoers').stdout.empty?
  }
  meet {
    shell "sed -i'' -e '/NOPASSWD/d' /etc/sudoers"
  }
end

dep 'sudo defaults', :username do
  setup {
    unmeetable! "This dep must be run as root." unless shell('whoami') == 'root'
  }
  met? {
    shell File.exist?("/etc/sudoers.d/defaults")
  }
  meet {
    shell "echo 'Defaults !tty_tickets,timestamp_timeout=15' >> /tmp/defaults"
    shell "chmod 440 /tmp/defaults"
    shell "mv /tmp/defaults /etc/sudoers.d/defaults"
  }
end
