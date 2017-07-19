require 'spec_helper'
describe 'host1fs' do

  context 'with defaults for all parameters' do
    it { should contain_class('host1fs') }
  end
end
