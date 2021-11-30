#
# Cookbook:: remote_rasterize
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

remote_file '/tmp/google-chrome-stable_current_amd64.deb' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
  not_if do ::File.exists?('/usr/bin/google-chrome') end
end

execute 'chrome_install' do
  command 'sudo apt-get -y install /tmp/google-chrome-stable_current_amd64.deb'
  action :run
  not_if do ::File.exists?('/usr/bin/google-chrome') end
end


apt_update

package ['python3-pip', 'zip', 'unzip'] do
  action :install
end

execute 'install_ipython' do
  command 'pip install ipython'
  action :run
  not_if do ::File.exists?('/usr/local/bin/ipython') end
end

user 'raster' do
  action :create
  system true
end

directory '/opt/remote_rasterize' do
  owner 'raster'
  group 'raster'
  mode '0755'
  action :create
end

template '/opt/remote_rasterize/remote_rasterize.py' do
  source 'remote_rasterize.py.erb'
  owner 'raster'
  group 'raster'
  mode '0644'
end


pip_packages = ['fastapi', 'pydantic', 'selenium', 'uvicorn', 'gunicorn']


pip_packages.each do |pip_pkg|

  execute "pip_#{pip_pkg}" do
    command "pip3 install #{pip_pkg} && touch /opt/remote_rasterize/pip_dep_#{pip_pkg}_installed"
    action :run
    not_if do ::File.exists?("/opt/remote_rasterize/pip_dep_#{pip_pkg}_installed") end
  end

end


execute 'get_chromedriver' do
  command 'wget http://chromedriver.storage.googleapis.com/`wget -q -O - http://chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip'
  action :run
  notifies :run, 'execute[install_chromedriver]'
  not_if do ::File.exists?('/usr/local/bin/chromedriver') end
end

execute 'install_chromedriver' do
  command 'unzip chromedriver_linux64.zip && mv chromedriver /usr/local/bin/'
  action :nothing
end


execute 'generate_certs' do
  command 'openssl req -newkey rsa:4096 -new -nodes -x509 -days 1826 -keyout /opt/remote_rasterize/key.pem -out /opt/remote_rasterize/cert.pem -subj "/C=US/ST=Washington/L=Seattle/O=KP/CN=remote.rasterize.com"'
  user 'raster'
  action :run
  not_if do ::File.exists?('/opt/remote_rasterize/key.pem') end
end


file '/var/log/remote_rasterize.log' do
  action :touch
  owner 'raster'
  group 'raster'
  mode '0644'
  not_if do ::File.exists?('/var/log/remote_rasterize.log') end
end

template '/etc/systemd/system/remote_rasterize.service' do
  source 'remote_rasterize.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

systemd_unit 'remote_rasterize.service' do
  action :enable
end

systemd_unit 'remote_rasterize.service' do
  action :start
end

