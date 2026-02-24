#*************************************
#*************************************
#***        Module CUPSem         ***
#***  Written by Jarek Tuszynski  ***
#***       January 3, 1993        ***
#***    Ruby Port by MelvinSGjr   ***
#***            (2026)            ***
#*************************************
#*************************************
require_relative 'version'
require_relative 'math'
require_relative 'matrix'
require_relative 'parser'
require_relative 'integral'
require_relative 'graphics'
require_relative 'gui'

module CUPSem
  class Error < StandardError; end
  
  #-------------------------- Configuration Class ------------------------
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
  
  #-------------------------- Global State ------------------------------
  @config = Configuration.new
  @initialized = false
  
  class << self
    attr_reader :config
    
    #-------------------------- Initialization ------------------------
    def init
      return if @initialized
      
      GUI::Mouse.init
      GUI::Viewport.define(0, 0, 0, 1, 1)
      GUI::Scale.define(0, 0, 1, 0, 1)
      
      @initialized = true
      puts "CUPSem initialized." if $DEBUG
    end
    
    #-------------------------- Cleanup -------------------------------
    def done
      @initialized = false
      @config.reset
    end
    
    def initialized?
      @initialized
    end
    
    #-------------------------- Error Handling ------------------------
    def announce(text)
      puts "Error: #{text}"
    end
    
    def grid_size
      @config.grid_size
    end
    
    def grid_size=(value)
      @config.grid_size = [[value, 10].max, 80].min
    end
    
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
    
    #-------------------------- User Input ----------------------------
    def pause
      print "Press Enter to continue..."
      gets
    end
    
    def dynamic_pause?
      false
    end
    
    def static_pause
      pause
    end
    
    #-------------------------- Number Formatting --------------------
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
    
    alias_method :Num2Str, :num_str
    alias_method :ScNumStr, :sc_num_str
  end
end

CUPSem.init

include CUPSem::Math
include CUPSem::Integral
include CUPSem::Derivative
