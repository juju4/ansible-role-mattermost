require 'serverspec'

# Required by serverspec
set :backend, :exec

describe service('mattermost') do
  it { should be_enabled }
  it { should be_running }
end

describe process("platform") do
  it { should be_running }
  its(:user) { should eq 'mattermost' }
  its(:count) { should eq 1 }
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

describe command('psql -c \'\\l\'') do
  let(:sudo_options) { '-u postgres' }
  its(:stdout) { should match /mattermost/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('psql -c \'\\dt\' mattermost') do
  let(:sudo_options) { '-u postgres' }
  its(:stdout) { should match /useraccesstokens/ }
  its(:stdout) { should match /incomingwebhooks/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end

describe command('curl -v http://localhost:8065') do
  its(:stdout) { should match /mattermost/ }
  its(:stdout) { should_not match /Cannot connect to Mattermost/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
describe command('curl -vk http://localhost:8443') do
  its(:stdout) { should match /mattermost/ }
  its(:stdout) { should_not match /Cannot connect to Mattermost/ }
  its(:stderr) { should match /TLS/ }
  its(:stderr) { should_not match /No such file or directory/ }
  its(:exit_status) { should eq 0 }
end
