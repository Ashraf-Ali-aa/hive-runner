require 'chamber'
require 'hive/log'
require 'hive/register'
require 'mind_meld'
require 'macaddr'
require 'socket'

# The Hive automated testing framework
module Hive
  Chamber.load(
    basepath: ENV['HIVE_CONFIG'] || './config/',
    namespaces: {
      environment: ENV['HIVE_ENVIRONMENT'] || 'test'
    }
  )
  DAEMON_NAME = Chamber.env.daemon_name? ? Chamber.env.daemon_name : 'HIVE'

  if Chamber.env.logging?
    if Chamber.env.logging.directory?
      LOG_DIRECTORY = Chamber.env.logging.directory
    else
      fail 'Missing log directory'
    end
    if Chamber.env.logging.pids?
      PIDS_DIRECTORY = Chamber.env.logging.pids
    else
      PIDS_DIRECTORY = LOG_DIRECTORY
    end
  else
    fail 'Missing logging section in configuration file'
  end

  @hivemind = MindMeld.new(url: Chamber.env.network.devicedb? ? Chamber.env.network.devicedb : nil)

  def self.config
    Chamber.env
  end

  def self.logger
    if ! @logger
      @logger = Hive::Log.new

      if Hive.config.logging.main_filename?
        @logger.add_logger("#{LOG_DIRECTORY}/#{Hive.config.logging.main_filename}", Chamber.env.logging.main_level? ? Chamber.env.logging.main_level : 'INFO')
      end
      if Hive.config.logging.console_level?
        @logger.add_logger(STDOUT, Hive.config.logging.console_level)
      end
    end
    @logger
  end

  def self.register
    @register ||= Hive::Register.new
  end

  # Get the id of the hive from the device database
  def self.id
    if ! @id
      Hive.logger.info "About to poll"
      reg = @hivemind.register(
        hostname: Hive.hostname,
        macs: [Hive.mac_address],
        ips: [Hive.ip_address],
        brand: Hive.config.brand? ? Hive.config.brand : 'BBC',
        model: Hive.config.model? ? Hive.config.model : 'Hive',
        device_type: 'hive'
       )
      @id = reg['id']
    end
    @id || -1
  end

  # Poll the device database
  def self.poll
    id = self.id
    if id and  id > 0
      Hive.logger.debug "Polling hive: #{id}"
#      rtn = @hivemind.poll(id)
#      Hive.logger.debug "Return data: #{rtn}"
#      if rtn['error'].present?
#        Hive.logger.warn "Hive polling failed: #{rtn['error']}"
#      else
#        Hive.logger.info "Successfully polled hive"
#      end
    else
      if id
        Hive.logger.debug "Skipping polling of hive"
      else
        Hive.logger.warn "Unable to poll hive"
      end
    end
  end

  # Get the IP address of the Hive
  def self.ip_address
    ip = Socket.ip_address_list.detect { |intf| intf.ipv4_private? }
    ip.ip_address
  end

  # Get the MAC address of the Hive
  def self.mac_address
    Mac.addr
  end

  # Get the hostname of the Hive
  def self.hostname
    Socket.gethostname.split('.').first
  end
end
