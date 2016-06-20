require 'spec_helper'

describe service('puma') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/apps/connec') do
  it { should be_directory }
end

describe file('/apps/connec/current') do
  it { should be_symlink }
end

describe file('/apps/connec/releases') do
  it { should be_directory }
end

describe file('/apps/connec/shared') do
  it { should be_directory }
end

describe command('curl http://localhost:3000/ping') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /ok/i }
end
