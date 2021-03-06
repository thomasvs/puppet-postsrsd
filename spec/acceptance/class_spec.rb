require 'spec_helper_acceptance'

describe 'postsrsd class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { '::tao': }

      class { 'postsrsd': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('postsrsd') do
      it { is_expected.to be_installed }
    end

    describe service('postsrsd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file('/etc/sysconfig/postsrsd') do
      it { should be_file }
      its(:content) { should match /^SRS_DOMAIN=localdomain/ }
      its(:content) { should match /^SRS_FORWARD_PORT=10001/ }
      its(:content) { should match /^SRS_REVERSE_PORT=10002/ }
    end

  end

  context 'custom parameters' do
    # Using puppet_apply as a helper
    it 'should work with different configuration' do
      pp = <<-EOS
      class { '::tao': }

      class { 'postsrsd':
        srs_domain => 'mydomain',
        srs_reverse_port => '9998',
        srs_forward_port => '9999',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/sysconfig/postsrsd') do
      it { should be_file }
      its(:content) { should match /^SRS_DOMAIN=mydomain/ }
      its(:content) { should match /^SRS_FORWARD_PORT=9999/ }
      its(:content) { should match /^SRS_REVERSE_PORT=9998/ }
    end


  end
end
