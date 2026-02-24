#************************************
#************************************
#***   Module Graphics (CUPS)     ***
#***  Written by Jarek Tuszynski  ***
#***        January 1993          ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
begin
  require 'numo/narray'
rescue LoadError
  # Numo::NArray not available - use plain arrays
  module Numo
    module NArray
      def self.zeros(*shape)
        Array.new(shape[0]) { Array.new(shape[1] || 1) { 0.0 } }
      end
      
      def self.linspace(start, finish, num)
        step = (finish - start) / (num - 1).to_f
        (0...num).map { |i| start + i * step }
      end
      
      class DFloat < Array
        def self.linspace(start, finish, num)
          step = (finish - start) / (num - 1).to_f
          DFloat.new((0...num).map { |i| start + i * step })
        end
        
        def initialize(arr = [])
          super(arr.is_a?(Array) ? arr.dup : arr)
        end
        
        def [](i, j = nil)
          j ? super[i][j] : super[i]
        end
        
        def []=(i, j, val)
          j ? self[i][j] = val : super(i, val)
        end
        
        def each
          each_with_index { |v, *idx| yield v, *idx }
        end
        
        def each_row
          each_with_index { |v, i, j| yield self[i] if j == 0 }
        end
        
        def min
          flatten.min
        end
        
        def max
          flatten.max
        end
        
        def n_rows
          size
        end
        
        def n_cols
          first&.size || 0
        end
        
        def **(other)
          map { |v| v ** other }
        end
        
        def +(other)
          if other.is_a?(DFloat)
            zip(other).map { |a, b| (a || 0) + (b || 0) }
          else
            map { |v| v + other }
          end
        end
        
        def /(other)
          if other.is_a?(DFloat)
            zip(other).map { |a, b| (a || 0) / (b.to_f.nonzero? || 1) }
          else
            map { |v| v / other.to_f }
          end
        end
        
        def to_a
          self
        end
        
        def sqrt
          DFloat.new(map { |v| Math.sqrt(v) })
        end
      end
    end
  end
end

module CUPSem
  module Graphics
    #-------------------------- Color Palettes -------------------
    module Palette
      # Rainbow palette (16 colors)
      RAINBOW = [
        0, 1, 9, 11, 3, 10, 2, 14, 6, 13, 5, 12, 4, 8, 7, 15
      ].freeze
      
      # Alternative rainbow
      RAINBOW2 = [
        0, 4, 12, 5, 13, 6, 14, 2, 10, 3, 11, 9, 1, 8, 7, 15
      ].freeze
      
      # Grayscale
      GRAYSCALE = (0..15).to_a.freeze
    end
    
    #-------------------------- 2D Plotting ----------------------
    class Plot2D
      attr_reader :data, :title, :xlabel, :ylabel
      attr_accessor :xmin, :xmax, :ymin, :ymax
      
      def initialize(title = "")
        @title = title
        @data = []
        @xlabel = "x"
        @ylabel = "y"
        @xmin = nil
        @xmax = nil
        @ymin = nil
        @ymax = nil
      end
      
      def set_labels(xlab, ylab)
        @xlabel = xlab
        @ylabel = ylab
      end
      
      def add_function(func, label = "", points: 100, range: nil)
        x_range = range || (@xmin..@xmax) || (0..10)
        xs = Numo::DFloat.linspace(x_range.begin, x_range.end, points)
        ys = xs.map { |x| func.call(x) }
        
        @data << {
          x: xs.to_a,
          y: ys.to_a,
          label: label,
          type: :function
        }
      end
      
      def add_data(xs, ys, label = "", style: :lines)
        @data << {
          x: xs.is_a?(Numo::NArray) ? xs.to_a : xs,
          y: ys.is_a?(Numo::NArray) ? ys.to_a : ys,
          label: label,
          type: :data,
          style: style
        }
      end
      
      def add_vector_field(ux, uy, xrange, yrange, scale: 1.0)
        # ux, uy are matrices of vector components
        @vector_data = {
          ux: ux,
          uy: uy,
          xrange: xrange,
          yrange: yrange,
          scale: scale
        }
      end
      
      # Save to file (PNG, EPS, etc.)
      def save(filename, terminal: 'png')
        output = filename == 'stdout' ? '' : "cairo font 'Helvetica 12'"
        
        commands = []
        commands << "set output '#{filename}'" unless filename == 'stdout'
        commands << "set terminal #{terminal} #{output}"
        
        # Set labels
        commands << "set xlabel '#{@xlabel}'"
        commands << "set ylabel '#{@ylabel}'"
        commands << "set title '#{@title}'"
        
        # Set ranges if specified
        commands << "set xrange [#{@xmin}:#{@xmax}]" if @xmin && @xmax
        commands << "set yrange [#{@ymin}:#{@ymax}]" if @ymin && @ymax
        
        # Grid
        commands << "set grid"
        
        # Plot commands
        plot_cmds = @data.each_with_index.map do |d, i|
          if d[:type] == :function
            "f#{i}(x) = #{d[:y].first}" # Simplified
          else
            "'-' using 1:2 with #{d[:style] || 'lines'} title '#{d[:label]}'"
          end
        end
        
        commands << "plot #{plot_cmds.join(', ')}"
        
        # Output data
        @data.each do |d|
          if d[:type] == :data
            d[:x].zip(d[:y]).each { |x, y| puts "#{x} #{y}" }
          end
        end
        
        commands.join("\n")
      end
    end
    
    #-------------------------- 3D Surface Plot ------------------
    class Plot3D
      attr_reader :title
      attr_accessor :xmin, :xmax, :ymin, :ymax, :zmin, :zmax
      
      def initialize(title = "")
        @title = title
        @matrix = nil
        @xmin = @xmax = @ymin = @ymax = @zmin = @zmax = nil
      end
      
      def set_matrix(matrix)
        @matrix = matrix
        auto_scale
      end
      
      def set_function(func, x_range, y_range, x_points: 25, y_points: 25)
        xs = Numo::DFloat.linspace(x_range.begin, x_range.end, x_points)
        ys = Numo::DFloat.linspace(y_range.begin, y_range.end, y_points)
        
        @matrix = Numo::DFloat.zeros(y_points, x_points)
        
        ys.each_with_index do |y, j|
          xs.each_with_index do |x, i|
            @matrix[j, i] = func.call(x, y)
          end
        end
        
        auto_scale
      end
      
      def auto_scale
        return unless @matrix
        
        @zmin = @matrix.min
        @zmax = @matrix.max
        
        if @zmax - @zmin < 1e-6
          @zmin -= 1
          @zmax += 1
        end
      end
      
      def save(filename, terminal: 'png')
        commands = []
        commands << "set terminal #{terminal} #{filename}"
        commands << "set title '#{@title}'"
        commands << "set xlabel 'x'"
        commands << "set ylabel 'y'"
        commands << "set zlabel 'z'"
        commands << "set hidden3d"
        commands << "set contour base"
        commands << "splot '-' with lines"
        
        # Output matrix data
        @matrix.each_row do |row|
          row.each { |v| print "#{v} " }
          puts
        end
        puts "e"
        
        commands.join("\n")
      end
    end
    
    #-------------------------- Contour Plot ---------------------
    class Contour
      attr_reader :title, :levels
      attr_accessor :palette
      
      def initialize(title = "")
        @title = title
        @matrix = nil
        @levels = 12
        @palette = 1
        @auto_levels = true
        @color_lines = true
      end
      
      def set_matrix(matrix)
        @matrix = matrix
      end
      
      def set_levels(n)
        @levels = n
        @auto_levels = false
      end
      
      def set_palette(num)
        @palette = num
      end
      
      def color_lines=(val)
        @color_lines = val
      end
      
      def auto_levels=(val)
        @auto_levels = val
      end
      
      def compute_levels
        return [] unless @matrix
        
        min_val = @matrix.min
        max_val = @matrix.max
        
        if @auto_levels
          @levels = @color_lines ? 12 : 11
        end
        
        (1..@levels).map do |i|
          min_val + (max_val - min_val) * i / (@levels + 1)
        end
      end
      
      def save(filename, terminal: 'png')
        levels = compute_levels
        
        commands = []
        commands << "set terminal #{terminal} #{filename}"
        commands << "set title '#{@title}'"
        commands << "set view map"
        commands << "set size square"
        commands << "set cntrparam levels #{@levels}"
        commands << "splot '-' with lines"
        
        commands.join("\n")
      end
    end
    
    #-------------------------- Vector Field ---------------------
    class VectorField
      def initialize
        @ux = nil
        @uy = nil
        @x_range = 0..10
        @y_range = 0..10
        @scale = 1.0
      end
      
      def set_data(ux, uy, x_range, y_range)
        @ux = ux
        @uy = uy
        @x_range = x_range
        @y_range = y_range
      end
      
      def scale=(val)
        @scale = val
      end
      
      # Generate gnuplot commands for quiver/vector plot
      def to_gnuplot
        return nil unless @ux && @uy
        
        # Calculate magnitude for coloring
        mag = Numo::NArray.sqrt(@ux**2 + @uy**2)
        max_mag = mag.max
        return nil if max_mag < 1e-10
        
        # Normalize and scale
        nx = @ux / max_mag * @scale
        ny = @uy / max_mag * @scale
        
        # Generate arrow data
        lines = []
        @ux.each_with_index do |_, i, j|
          x = @x_range.begin + j * (@x_range.end - @x_range.begin) / (@ux.n_cols - 1)
          y = @y_range.begin + i * (@y_range.end - @y_range.begin) / (@ux.n_rows - 1)
          lines << "#{x} #{y} #{nx[i, j]} #{ny[i, j]}"
        end
        
        lines.join("\n")
      end
    end
    
    #-------------------------- Legend ---------------------------
    class Legend
      def initialize
        @items = []
      end
      
      def add(label, color, style: :line)
        @items << { label: label, color: color, style: style }
      end
      
      def to_s
        @items.map { |i| "#{i[:label]}: #{i[:style]}" }.join("\n")
      end
    end
  end
end