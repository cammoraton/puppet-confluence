require 'spec_helper'

describe 'confluence', :type => :class do
  context "on an Ubuntu OS" do
    let :facts do
      {
         :osfamily               => 'Debian',
         :operatingsystemrelease => '14.04',
      }
    end
  end
end