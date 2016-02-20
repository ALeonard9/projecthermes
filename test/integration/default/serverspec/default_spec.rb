require 'spec_helper'

describe 'projectorion::default' do
  services = ['httpd']

  services.each do |srv|
    describe service(srv) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  ports = ['80']

  ports.each do |prt|
    describe port(prt) do
      it { should be_listening }
    end
  end

  describe command('curl localhost') do
    its(:stdout) { should match(/Leonine/) }
  end
end
