require 'spec_helper'

describe 'confluence', :type => :class do
  it { should include_class("confluence::params") }
  it { should contain_class("confluence::apache") }
end