require 'serverspec'

# Required by serverspec
set :backend, :exec

describe service('mattermost') do
  it { should be_enabled }
  it { should be_running }
end

describe process("mattermost") do
  it { should be_running }
  its(:user) { should eq 'mattermost' }
  # only one, but with v5, serverspec see more, likely postgres ones...
  its(:count) { should > 1 }
end

describe port(8065) do
  it { should be_listening }
end
describe port(8443) do
  it { should be_listening }
end

describe file('/opt/mattermost/config/config.json') do
  it { should contain 'ServiceSettings' }
  it { should contain 'TeamSettings' }
end
describe file('/etc/nginx/conf.d/mattermost.conf') do
  it { should contain 'server 127.0.0.1:8065' }
  it { should contain 'location ~ /api/v[0-9]+/(users/)?websocket$ {' }
end
describe file('/opt/mattermost/logs/mattermost.log') do
  it { should contain 'Starting Server...' }
  it { should_not contain 'ERROR' }
end

describe command('sudo -u postgres psql -c \'\\l\'') do
  its(:stdout) { should match /mattermost/ }
  #its(:stderr) { should match /^$/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('sudo -u postgres psql -c \'\\dt\' mattermost') do
  its(:stdout) { should match /useraccesstokens/ }
  its(:stdout) { should match /incomingwebhooks/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end

describe command('sudo -u mattermost /opt/mattermost/bin/mattermost user search joe') do
  its(:stdout) { should match /username: joe/ }
  its(:stdout) { should match /email: joe@example.com/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('sudo -u mattermost /opt/mattermost/bin/mattermost team list') do
  its(:stdout) { should match /myteam/ }
  its(:stdout) { should match /private/ }
  its(:stdout) { should match /8soyabwthjnf9qibfztje5a36h/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('sudo -u mattermost /opt/mattermost/bin/mattermost channel list myteam') do
  its(:stdout) { should match /mynewchannel/ }
  its(:stdout) { should match /mynewprivatechannel \(private\)/ }
  its(:stdout) { should match /town-square/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end

describe command('curl -v http://localhost:8065') do
  its(:stdout) { should match /Mattermost/ }
  ## below content is expect if no javascript
  its(:stdout) { should match /Cannot connect to Mattermost/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('curl -vk https://localhost:8443') do
  its(:stdout) { should match /Mattermost/ }
  its(:stdout) { should match /Cannot connect to Mattermost/ }
  its(:stderr) { should match /TLS/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('curl -vk https://localhost:8443/login') do
  its(:stdout) { should match /Mattermost/ }
  its(:stdout) { should match /Cannot connect to Mattermost/ }
  its(:stderr) { should match /TLS/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
