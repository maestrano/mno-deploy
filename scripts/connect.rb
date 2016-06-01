#!/usr/bin/env ruby

# ----------------------------------------------------------
# Script to connect to an EC2 instance running inside a VPC
# ----------------------------------------------------------

# SSH keys must be stored under
# ~/.ssh/VPC_NAME/jumphost.pem  # Jumphost SSH key
# ~/.ssh/VPC_NAME/instance.pem  # Instance SSH key

# Evironment variables
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_REGION=

require 'rubygems'
require 'aws-sdk'
require 'highline'

# Check environment variables
%w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION).each do |prop|
  next if ENV[prop]
  puts "Environment variable #{prop} must be set"
  exit 1
end

# Extract a resource name from Tag
def tag_name(resource)
  tag_name = resource.tags.find{|tag| tag.key == 'Name'}
  name = tag_name ? tag_name.value : nil
end

# CLI Prompt
cli = HighLine.new

# List available VPCs
ec2 = Aws::EC2::Client.new
vpcs = ec2.describe_vpcs.vpcs
if vpcs.any?
  vpcs.each_with_index do |vpc, index|
    puts "#{index+1}: #{vpc.vpc_id} - #{tag_name(vpc)}"
  end
else
  puts "No VPC found in this region"
  exit 1
end

# VPC number
vpc_number = cli.ask("Select your VPC: ") { |q| q.default = "1" }
vpc_id = vpcs[vpc_number.to_i-1].vpc_id

# EC2 Instances
vpc = Aws::EC2::Vpc.new vpc_id
vpc_name = tag_name(vpc)
instances = vpc.instances.sort{|i1,i2| tag_name(i1) <=> tag_name(i2)}
instances.each_with_index do |instance, index|
  puts "#{index+1}: #{instance.id}\t#{tag_name(instance)}\t#{instance.private_ip_address}"
end

# Instance number
instance_number = cli.ask("Select your Instance: ") { |q| q.default = "1" }
instance = instances[instance_number.to_i-1]

ami = Aws::EC2::Image.new instance.image_id
instance_user = ami.name.include?('amzn-ami') ? 'ec2-user' : 'ubuntu'

# Find NAT instance
nat = instances.find{|i| tag_name(i).end_with?('-nat') }
if nat
  ami = Aws::EC2::Image.new nat.image_id
  linux_username = ami.name.include?('amzn-ami') ? 'ec2-user' : 'ubuntu'
  jumpbox_ip = nat.public_ip_address
else
  jumpbox_ip = cli.ask("Enter the public Jumpbox IP: ")
  linux_username = cli.ask("Enter the Jumpbox SSH username: ") { |q| q.default = "ec2-user" }
end

jumphost_key = File.expand_path("~/.ssh/#{vpc_name}/jumphost.pem")
instance_key = File.expand_path("~/.ssh/#{vpc_name}/instance.pem")
unless File.exist?(jumphost_key)
  puts "Jumphost SSH key cannot be found: #{jumphost_key}"
  exit(1)
end
unless File.exist?(instance_key)
  puts "Instance SSH key cannot be found: #{instance_key}"
  exit(1)
end

# SSH command
command = "ssh -vvv -i #{instance_key} \
-o UserKnownHostsFile=/dev/null  \
-o StrictHostKeyChecking=no \
-o \"ProxyCommand ssh -W %h:%p -i #{jumphost_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{linux_username}@#{jumpbox_ip}\" \
ubuntu@#{instance.private_ip_address}"

puts "Executing command: #{command}"
exec command
