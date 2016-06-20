require 'spec_helper'

def rs_status_cmd
  user = INVENTORY['vars']['mongodb_admin']
  "mongo -quiet -u #{user['login']} -p #{user['password']} --eval 'printjson(rs.status())' admin"
end

def connec_db_status_cmd
  user = INVENTORY['vars']['mongodb_connec']
  "mongo -quiet -u #{user['login']} -p #{user['password']} --eval 'printjson(db.stats())' #{user['db']}"
end

describe service('mongod') do
  it { should be_running }
end

describe file('/data/db') do
  it { should be_directory }
end

describe command(rs_status_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('"set" : "rs0"') }
  its(:stdout) { should contain('"name" : "r0.mongo') }
  its(:stdout) { should contain('"name" : "r1.mongo') }
  its(:stdout) { should contain('"name" : "r2.mongo') }
end

describe command(connec_db_status_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('"db"') }
  its(:stdout) { should contain('"fileSize"') }
  its(:stdout) { should contain('"indexes"') }
  its(:stdout) { should contain('"ok" : 1') }
end
