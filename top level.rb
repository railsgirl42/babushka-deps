dep 'system' do
  requires 'hostname', 'secured ssh logins', 'lax host key checking', 'admins can sudo', 'tmp cleaning grace period'
end

dep 'user setup' do
  requires 'dot files', 'passwordless ssh logins', 'public key'
  define_var :username, :default => shell('whoami')
  setup {
    set :username, shell('whoami')
    set :home_dir_base, "/home"
  }
end

dep 'rails app' do
  requires 'webapp', 'passenger deploy repo', 'gems installed', 'migrated db'
  define_var :rails_env, :default => 'production'
  define_var :rails_root, :default => '~/current', :type => :path
  setup {
    set :vhost_type, 'passenger'
  }
end

# dep 'proxied app' do
#   requires 'webapp'
#   setup {
#     set :vhost_type, 'proxy'
#   }
# end

dep 'webapp' do
  requires 'user exists', 'vhost enabled', 'webserver running'
  define_var :domain, :default => :username
  setup {
    set :home_dir_base, "/home/www"
  }
end

dep 'core software' do
  requires {
    on :linux, 'curl', 'screen', 'nmap', pkg('tree')
    on :osx, 'curl', 'jnettop', 'nmap'
  }
end

dep 'lampr server' do
  requires 'system', 'rails server', 'php server'
end

