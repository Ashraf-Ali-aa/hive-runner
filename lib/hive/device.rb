require 'hive'

module Hive
  # The generic device class
  class Device
    attr_reader :type
    attr_reader :worker_pid

    # Initialise the device
    def initialize(options)
      @worker_pid = nil
      @options = options
      @worker_class = self.class.to_s.sub('Device', 'Worker')
      require @worker_class.downcase.gsub(/::/, '/')
      raise ArgumentError "Identity not set for #{self.class} device" if ! @identity
    end

    # Start the worker process
    def start
      parent_pid = Process.pid
      @worker_pid = Process.fork do
        worker = Object.const_get(@worker_class).new(parent_pid, @options)
      end
      Process.detach @worker_pid

      Hive.logger.info("Worker started with pid #{@worker_pid}")
    end

    # Terminate the worker process
    def stop
      Process.kill 'TERM', @worker_pid
    end

    # Test the state of the worker process
    def running?
      if @worker_pid
        begin
          Process.kill 0, @worker_pid
          true
        rescue Errno::ESRCH
          false
        end
      else
        false
      end
    end

    # Test equality with another device
    def ==(other)
      self.identity == other.identity
    end

    # Return the unique identity of the device
    def identity
      "#{self.class}-#{@identity}"
    end
  end
end
