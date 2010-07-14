dep 'apache setup' do
  requires 'apache2'
end

pkg 'apache2' do
  installs {
    via :apt, %w[apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert apache2-prefork-dev libapr1-dev libaprutil1-dev]
  }
end

dep 'apache etag support' do
  met? { File.exist? '/etc/apache2/conf.d/etag' }
  meet {
    File.open '/etc/apache2/conf.d/etag', 'w' do |f|
      f << <<-conf
FileETag MTime Size
conf
    end
  }
end

dep 'apache deflate support' do
  met? { File.exist? '/etc/aapche/conf.d/deflate' }
  meet {
    File.open '/etc/apache2/conf.d/deflate', 'w' do |f|
      f << <<-conf
# Passenger-stack-deflate
<IfModule mod_deflate.c>
# compress content with type html, text, and css
AddOutputFilterByType DEFLATE text/css text/html text/javascript application/javascript application/x-javascript text/js text/plain text/xml
<IfModule mod_headers.c>
# properly handle requests coming from behind proxies
Header append Vary User-Agent
</IfModule>
</IfModule>
conf
    end
  }
end

dep 'apache expires support' do
  met? { File.exist? '/etc/apache2/conf.d/expires' }
  meet {
    File.open '/etc/apache2/conf.d/expires', 'w' do |f|
      f << <<-conf
# Passenger-stack-expires
<IfModule mod_expires.c>
<FilesMatch "\.(jpg|gif|png|css|js)$">
ExpiresActive on
ExpiresDefault "access plus 1 year"
</FilesMatch>
</IfModule>
conf
    end
  }
end

