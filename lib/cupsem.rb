require_relative 'cupsem/version'
require_relative 'cupsem/math'
require_relative 'cupsem/matrix'
require_relative 'cupsem/parser'
require_relative 'cupsem/integral'
require_relative 'cupsem/graphics'
require_relative 'cupsem/gui'

module CUPSem
  class Error < StandardError; end
  
  # Global configuration
  class Configuration
    attr_accessor :grid_size, :integration_points, :plot_resolution
    attr_accessor :halt_on_error, :error_found
    attr_accessor :delay_time, :double_click_time
    
    def initialize
      reset
    end
    
    def reset
      @grid_size = 30
      @integration_points = 200
      @plot_resolution = 30
      @halt_on_error = true
      @error_found = false
      @delay_time = 0
      @double_click_time = 10
    end
  end
  
  # Global state
  @config = Configuration.new
  @initialized = false
  
  class << self
    attr_reader :config
    
    # Initialize the library
    def init
      return if @initialized
      
      # Initialize components
      GUI::Mouse.init
      GUI::Viewport.define(0, 0, 0, 1, 1)  # Default full viewport
      GUI::Scale.define(0, 0, 1, 0, 1)     # Default scale
      
      @initialized = true
      puts "CUPSem initialized." if $DEBUG
    end
    
    # Clean up
    def done
      @initialized = false
      @config.reset
    end
    
    # Check if initialized
    def initialized?
      @initialized
    end
    
    # Announce error message
    def announce(text)
      puts "Error: #{text}"
    end
    
    # Configuration helpers
    def grid_size
      @config.grid_size
    end
    
    def grid_size=(value)
      @config.grid_size = [[value, 10].max, 80].min
    end
    
    # Error handling
    def halt_if_error?
      @config.halt_on_error
    end
    
    def halt_if_error=(value)
      @config.halt_on_error = value
    end
    
    def error_found?
      @config.error_found
    end
    
    def error_found=(value)
      @config.error_found = value
    end
    
    # Pause/wait for user input
    def pause
      print "Press Enter to continue..."
      gets
    end
    
    # Dynamic pause (non-blocking check)
    def dynamic_pause?
      # In terminal, just check if input available
      false
    end
    
    # Static pause (blocking wait)
    def static_pause
      pause
    end
    
    # Number to string conversion
    def num_str(num, width, decimals)
      format("%#{width}.#{decimals}f", num).strip
    end
    
    def sc_num_str(num, decimals = 3)
      return "0" if num == 0
      
      mag = Math.log(num.abs) / Math.log(10)
      mag = mag.to_i
      
      if mag != 0
        "#{num_str(num / 10.0**mag, decimals + 3, decimals)}E#{mag}"
      else
        num_str(num, decimals + 3, decimals)
      end
    end
    
    # Alias for compatibility
    alias_method :Num2Str, :num_str
    alias_method :ScNumStr, :sc_num_str
  end
end

# Auto-initialize when required
CUPSem.init

# Convenience includes
include CUPSem::Math
include CUPSem::Integral
include CUPSem::Derivative
