require 'spec_helper'
require 'hive/register'

describe Hive::Register do
  let(:register) { Hive::Register.new }

  describe '#instantiate_controllers' do
    it 'instantiates a test controller' do
      ENV['HIVE_ENVIRONMENT'] = 'test_daemon_helper_instantiate'
      load File.expand_path('../../../lib/hive.rb', __FILE__)
      register.instantiate_controllers
      expect(register.controllers[0]).to be_a Hive::Controller::Shell
    end
  end

  describe '#devices' do
    it 'returns the list of devices from a single controller' do
      ENV['HIVE_ENVIRONMENT'] = 'test_daemon_helper_single_controller'
      load File.expand_path('../../../lib/hive.rb', __FILE__)
      register.instantiate_controllers
      d = register.devices
      expect(d).to be_an Array
      expect(d.length).to be 5
    end
  end
end
