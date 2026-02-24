#************************************
#************************************
#***      Module GUI (CUPS)       ***
#***  Written by Jarek Tuszynski  ***
#***        January 1993          ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
require 'forwardable'

module CUPSem
  module GUI
    #-------------------------- Base Widget ----------------------
    class Widget
      attr_accessor :x, :y, :width, :height, :visible
      attr_reader :parent
      
      def initialize(x: 0, y: 0, width: 100, height: 30)
        @x = x
        @y = y
        @width = width
        @height = height
        @visible = true
        @parent = nil
      end
      
      def show
        @visible = true
        self
      end
      
      def hide
        @visible = false
        self
      end
      
      def contains?(px, py)
        px >= @x && px <= @x + @width && py >= @y && py <= @y + @height
      end
    end
    
    #-------------------------- Menu System ----------------------
    class Menu
      attr_reader :columns, :active, :col_chosen, :row_chosen
      
      def initialize
        @columns = {}
        @active = false
        @col_chosen = 0
        @row_chosen = 0
        @hotkey_handlers = {}
      end
      
      def init
        @columns = {}
        @active = false
        self
      end
      
      def column(col_num, title)
        @columns[col_num] ||= { title: title, rows: {} }
      end
      
      def row(col_num, row_num, label)
        @columns[col_num][:rows][row_num] = label
      end
      
      def display
        # Render menu to terminal
        puts "Menu:"
        @columns.each do |col_num, col|
          puts "  #{col[:title]}"
          col[:rows].each do |row_num, label|
            puts "    #{row_num}. #{label}"
          end
        end
        @active = true
      end
      
      def activated?
        @active
      end
      
      def chosen?
        @col_chosen > 0 && @row_chosen > 0
      end
      
      def handle_key(key)
        # Simple keyboard handling
        case key
        when '1'..'9'
          @col_chosen = key.to_i
          @active = false
          true
        else
          false
        end
      end
      
      def done
        @columns = {}
        @active = false
      end
    end
    
    #-------------------------- Hot Keys --------------------------
    class HotKeys
      attr_reader :keys, :count
      
      def initialize
        @keys = {}
        @count = 0
      end
      
      def init(num_keys)
        @keys = {}
        @count = num_keys
        self
      end
      
      def []=(index, label)
        @keys[index] = label
      end
      
      def [](index)
        @keys[index]
      end
      
      def display
        puts "Hot Keys: " + @keys.values.join(" | ")
      end
      
      def pressed(key)
        # Check if key matches any hotkey
        @keys.each do |idx, label|
          return idx if label.include?(key.to_s)
        end
        nil
      end
    end
    
    #-------------------------- Input Screen ---------------------
    class InputScreen
      attr_reader :canceled, :values
      
      def initialize
        @title = ""
        @fields = []
        @canceled = false
        @values = {}
      end
      
      def init
        @fields = []
        @canceled = false
        @values = {}
        self
      end
      
      def define_input_port(x1, y1, x2, y2)
        # Not used in terminal version - placeholder
        self
      end
      
      def load_line(text)
        @fields << text
        self
      end
      
      def set_radio_button(name, value)
        @values["radio_#{name}"] = value
        self
      end
      
      def get_radio_button(name)
        @values["radio_#{name}"] || 1
      end
      
      def set_string(field_num, value)
        @values["string_#{field_num}"] = value
        self
      end
      
      def get_string(field_num)
        @values["string_#{field_num}"] || ""
      end
      
      def set_number(field_num, value)
        @values["number_#{field_num}"] = value
        self
      end
      
      def get_number(field_num)
        @values["number_#{field_num}"] || 0
      end
      
      def set_number_limits(field_num, min, max)
        @values["limits_#{field_num}"] = [min, max]
        self
      end
      
      def set_help_screen(help_text)
        @help = help_text
        self
      end
      
      def accept_screen
        # In terminal version, show interactive prompt
        puts "\n" + "=" * 50
        puts @title
        puts "=" * 50
        
        @fields.each_with_index do |field, idx|
          next if field.include?('[') || field.strip.empty?
          
          if field.include?('#')
            # Input field
            print field.gsub(/#.*$/, '').strip + ": "
            input = gets
            if input.nil? || input.strip.empty?
              @canceled = true
              break
            end
            @values["field_#{idx}"] = input.strip
          else
            puts field
          end
        end
        
        self
      end
      
      def done
        # Clean up
        self
      end
    end
    
    #-------------------------- Slider Control -------------------
    class Slider
      attr_reader :value, :min, :max
      
      def initialize(min, max, initial = min)
        @min = min
        @max = max
        @value = initial
        @changed = false
      end
      
      def value=(v)
        @value = [@min, [@max, v].min].max
        @changed = true
      end
      
      def changed?
        @changed
      end
      
      def reset_changed
        @changed = false
      end
      
      def create(x, y, width, label = "")
        # Placeholder for GUI implementation
        self
      end
      
      def draw_all
        # Placeholder
      end
      
      def erase(color = 0)
        # Placeholder
      end
      
      def done
        # Placeholder
      end
    end
    
    #-------------------------- Sliders Container ----------------
    class Sliders
      def initialize
        @sliders = {}
      end
      
      def init
        @sliders = {}
        self
      end
      
      def create(id, min, max, initial, x1, y1, x2, y2, label1, label2, label3, horizontal)
        @sliders[id] = Slider.new(min, max, initial)
        @sliders[id].create(x1, y1, x2, y2, label1)
        self
      end
      
      def value(id)
        @sliders[id] ? @sliders[id].value : 0
      end
      
      def changed
        @sliders.values.any?(&:changed?)
      end
      
      def reset_changed
        @sliders.values.each(&:reset_changed)
      end
      
      def draw_all
        @sliders.values.each(&:draw_all)
      end
      
      def erase(id, color = 0)
        @sliders[id]&.erase(color)
      end
      
      def done
        @sliders = {}
      end
    end
    
    #-------------------------- Mouse Handling -------------------
    module Mouse
      class << self
        attr_accessor :present, :x, :y, :button
        
        def init
          @present = false
          @x = 0
          @y = 0
          @button = 0
        end
        
        def detect
          # In terminal, no mouse - always false
          @present = false
        end
        
        def global_posn
          [@x, @y, @button]
        end
        
        def clicked?
          @button != 0
        end
        
        def show
          # No-op in terminal
        end
        
        def hide
          # No-op in terminal
        end
      end
    end
    
    #-------------------------- Viewport Management --------------
    class Viewport
      attr_reader :number, :x1, :y1, :x2, :y2
      
      @@current = 0
      @@viewports = {}
      
      def self.define(number, x1, y1, x2, y2)
        @@viewports[number] = new(number, x1, y1, x2, y2)
      end
      
      def self.select(number)
        @@current = number
      end
      
      def self.current
        @@viewports[@@current]
      end
      
      def self.close(number)
        @@viewports.delete(number)
      end
      
      def initialize(number, x1, y1, x2, y2)
        @number = number
        @x1 = x1
        @y1 = y1
        @x2 = x2
        @y2 = y2
      end
      
      def contains?(px, py)
        px >= @x1 && px <= @x2 && py >= @y1 && py <= @y2
      end
    end
    
    #-------------------------- Scale Management -----------------
    class Scale
      attr_reader :number, :xmin, :xmax, :ymin, :ymax
      
      @@current = 0
      @@scales = {}
      
      def self.define(number, xmin, xmax, ymin, ymax)
        @@scales[number] = new(number, xmin, xmax, ymin, ymax)
      end
      
      def self.select(number)
        @@current = number
      end
      
      def self.current
        @@scales[@@current]
      end
      
      def initialize(number, xmin, xmax, ymin, ymax)
        @number = number
        @xmin = xmin
        @xmax = xmax
        @ymin = ymin
        @ymax = ymax
      end
      
      def map_x(x)
        # Map from data coordinates to screen
        ((x - @xmin) / (@xmax - @xmin)).to_i
      end
      
      def map_y(y)
        # Map from data coordinates to screen (inverted y)
        ((@ymax - y) / (@ymax - @ymin)).to_i
      end
    end
    
    #-------------------------- Environment ----------------------
    class Environment
      def save
        # Save current color, viewport, line style, etc.
        @state = {
          color: 0,
          viewport: Viewport.current,
          scale: Scale.current
        }
        
        self
      end
      
      def standardize
        # Set default settings
        Scale.define(0, 0, 1, 0, 1)
        self
      end
      
      def reset
        # Restore saved state
        Scale.select(@state[:scale].number) if @state[:scale]
        self
      end
    end
    
    #-------------------------- Wait Message ---------------------
    class WaitMessage
      def initialize
        @shown = false
        @counter = 0
        @spinner = "|/-\\"
      end
      
      def show
        @shown = true
        print "Calculating"
      end
      
      def update
        return unless @shown
        print "."
        @counter = (@counter + 1) % 4
      end
      
      def hide
        @shown = false
        puts " Done!"
      end
    end
  end
end