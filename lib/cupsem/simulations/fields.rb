#************************************
#************************************
#***      Module FIELDS (CUPS)    ***
#***  Written by Jarek Tuszynski  ***
#***       January 3, 1993        ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
require_relative '../cupsem'
require_relative '../matrix'
require_relative '../parser'
require_relative '../graphics'
require_relative '../gui'

module CUPSem
  module Simulations
    #-------------------------- Scalar Field ----------------------
    class ScalarField
      attr_reader :scalar1, :scalar2, :vector1, :magn1, :magn2
      attr_reader :min, :max, :center, :h
      attr_reader :equation, :plane_norm, :coordinates
      attr_accessor :integral_on, :active, :probe
      
      def initialize(size: 30)
        @size = size
        @scalar1 = DMatrix.new(size, size)
        @scalar2 = DMatrix.new(size, size)  # Laplacian
        @vector1 = Array.new(3) # DMatrix.new(size, size) 
        @magn1 = DMatrix.new(0, 0)
        @magn2 = DMatrix.new(0, 0)
        
        # Coordinate bounds
        @min = Point3D.new(-1, -1, -1)
        @max = Point3D.new(1, 1, 1)
        @center = Point3D.new(0, 0, 0)
        @h = [0.0, 0.0, 0.0]
        
        # Default equation
        @equation = ["x*y+z*r", "", ""]
        
        # Settings
        @plane_norm = 3  # xy-plane
        @coordinates = 1  # x,y,z
        @active = false
        @integral_on = false
        @probe = false
        
        # Small value threshold
        @small = 1e-10
        
        # Initialize step sizes
        define_scale
      end
      
      #-------------------------- Define Scale -------------------
      def define_scale
        @h[0] = (@max.x - @min.x) / (@size - 1)
        @h[1] = (@max.y - @min.y) / (@size - 1)
        @h[2] = 0.01
      end
      
      # Read function from user input
      def read_function
        screen = GUI::InputScreen.new
        screen.define_input_port(0.04, 0.96, 0.27, 0.73)
        screen.load_line("Input Scalar Field Function")
        screen.load_line("Choose coordinates: F(x,y,z) / F(r,phi,z) / F(rho,theta,phi)")
        
        # Interactive input
        puts "\n=== Scalar Field Input ==="
        puts "Enter function (e.g., x*y + z*r):"
        print "> "
        func_str = gets&.strip
        
        return false if func_str.nil? || func_str.empty?
        
        @equation[0] = func_str
        @active = true
        
        find_field
        true
      end
      
      #-------------------------- Choose Graphs ------------------
      def choose_graphs
        puts "\n=== Choose Graphs ==="
        puts "1. Scalar Field F"
        puts "2. Grad F (Vector)"
        puts "3. Magnitude of Grad F"
        puts "4. dF/dx"
        puts "5. dF/dy"
        puts "6. dF/dz"
        puts "7. Laplacian F"
        
        print "Select option (1-7): "
        choice = gets&.strip
        
        @plot_num = choice.to_i if choice
        draw_plots
      end
      
      #-------------------------- Find Field ---------------------
      def find_field
        return unless @active && @equation[0] && !@equation[0].empty?
        
        parser = Parser.new
        
        # Set coordinate system variables
        parser.set_real_variable('theta', 0) if @coordinates == 3
        parser.set_real_variable('rho', 0) if @coordinates == 3
        parser.set_real_variable('phi', 0) if @coordinates > 1
        
        # Parse the function
        xyz = ['x', 'y', 'z']
        i, j, k = get_plane_indices
        
        ok = parser.parse(xyz[i], xyz[j], xyz[k], 'r', @equation[0])
        
        if ok
          create_matrix(parser)
          find_grad_laplacian(parser)
        else
          CUPSem.announce("Error: Cannot evaluate function")
        end
      end
      
      def get_plane_indices
        case @plane_norm
        when 1 then [1, 2, 0]  # yz-plane
        when 2 then [2, 0, 1]  # zx-plane
        when 3 then [0, 1, 2]  # xy-plane
        else [0, 1, 2]
        end
      end
      
      #-------------------------- Create Matrix ------------------
      def create_matrix(parser)
        wait = GUI::WaitMessage.new
        wait.show
        
        i, j, k = get_plane_indices
        
        hx = (@max.to_a[i] - @min.to_a[i]) / (@size - 1)
        hy = (@max.to_a[j] - @min.to_a[j]) / (@size - 1)
        
        (1..@size).each do |row|
          (1..@size).each do |col|
            x = @min.to_a[i] + (col - 1) * hx
            y = @max.to_a[j] - (row - 1) * hy
            z = @center.to_a[k]
            
            value = evaluate_with_coords(parser, x, y, z, i, j, k)
            @scalar1.put(row, col, value)
          end
          wait.update
        end
        
        wait.hide
      end
      
      def evaluate_with_coords(parser, x, y, z, i, j, k)
        # Map coordinates based on plane
        case @plane_norm
        when 1
          xx, yy, zz = z, x, y
        when 2
          xx, yy, zz = y, z, x
        else
          xx, yy, zz = x, y, z
        end
        
        r = Math.sqrt(xx*xx + yy*yy)
        
        parser.set_real_variable('theta', Math.atan2(zz, r)) if @coordinates == 3
        parser.set_real_variable('rho', Math.sqrt(r*r + zz*zz)) if @coordinates == 3
        parser.set_real_variable('phi', Math.atan2(xx, yy)) if @coordinates > 1
        
        parser.f(x, y, z, r)
      end
      
      def find_grad_laplacian(parser)
        wait = GUI::WaitMessage.new
        wait.show
        
        i, j, k = get_plane_indices
        
        (1..@size).each do |row|
          (1..@size).each do |col|
            x = @min.to_a[i] + (col - 1) * @h[i]
            y = @max.to_a[j] - (row - 1) * @h[j]
            z_center = @center.to_a[k]
            
            # Get values at different z positions for derivatives
            v1 = evaluate_with_coords(parser, x, y, z_center - 2*@h[k], i, j, k)
            v2 = evaluate_with_coords(parser, x, y, z_center - @h[k], i, j, k)
            v3 = @scalar1.value(row, col)
            v4 = evaluate_with_coords(parser, x, y, z_center + @h[k], i, j, k)
            v5 = evaluate_with_coords(parser, x, y, z_center + 2*@h[k], i, j, k)
            
            # Gradients (central differences)
            @vector1[i].put(row, col, @scalar1.dmdx(row, col, @h[i]))
            @vector1[j].put(row, col, -@scalar1.dmdy(row, col, @h[j]))
            @vector1[k].put(row, col, (v1 - 8*v2 + 8*v4 - v5) / (12 * @h[k]))
            
            # Laplacian
            @scalar2.put(row, col, (-v1 + 16*v2 - 30*v3 + 16*v4 - v5) / (12 * @h[k]**2))
          end
          wait.update
        end
        
        # Add divergence of gradient to Laplacian
        (1..@size).each do |row|
          (1..@size).each do |col|
            laplacian = @scalar2.value(row, col)
            laplacian += @vector1[i].dmdx(row, col, @h[i])
            laplacian -= @vector1[j].dmdy(row, col, @h[j])
            @scalar2.put(row, col, laplacian)
          end
        end
        
        # Clean up small values
        3.times do |idx|
          min_val, max_val = @vector1[idx].minmax(1, @size, 1, @size)
          if max_val - min_val < @small
            if min_val * max_val < 0
              @vector1[idx].fill(0)
            else
              @vector1[idx].fill((min_val + max_val) / 2)
            end
          end
        end
        
        min_val, max_val = @scalar2.minmax(1, @size, 1, @size)
        if max_val - min_val < @small
          if min_val * max_val < 0
            @scalar2.fill(0)
          else
            @scalar2.fill((min_val + max_val) / 2)
          end
        end
        
        wait.hide
      end
      
      # Draw plots
      def draw_plots
        return unless @active
        
        case @plot_num
        when 1
          plot_scalar_field
        when 2
          plot_vector_field
        when 3
          plot_magnitude
        when 4, 5, 6
          plot_derivative(@plot_num - 3)
        when 7
          plot_laplacian
        end
      end
      
      def plot_scalar_field
        puts "\nPlotting Scalar Field F = ##@equation[0]"
        # Would use Graphics module here
        # For now, print some values
        puts "Value at center: ##@scalar1.value(@size/2, @size/2)"
      end
      
      def plot_vector_field
        puts "\nPlotting Gradient of F"
      end
      
      def plot_magnitude
        puts "\nPlotting Magnitude of Grad F"
      end
      
      def plot_derivative(axis)
        axes = ['x', 'y', 'z']
        puts "\nPlotting dF/d##axes[axis-1]"
      end
      
      def plot_laplacian
        puts "\nPlotting Laplacian of F"
      end
      
      # Resize grid
      def resize(rows, cols)
        @size = [rows, cols].max
        
        @scalar1 = DMatrix.new(@size, @size)
        @scalar2 = DMatrix.new(@size, @size)
        @vector1 = Array.new(3) # DMatrix.new(@size, @size) 
        
        define_scale
        find_field
      end
      
      # Define plane for 2D slice
      def define_plane(plane = 3, center_val = 0)
        @plane_norm = plane
        @center = case plane
                  when 1 then Point3D.new(center_val, @center.y, @center.z)
                  when 2 then Point3D.new(@center.x, center_val, @center.z)
                  when 3 then Point3D.new(@center.x, @center.y, center_val)
                  else @center
                  end
        find_field
      end
      
      # Field probe (mouse interaction)
      def field_probe(x, y)
        return unless @probe
        
        i, j, k = get_plane_indices
        
        px = @min.to_a[i] + (x - 1) * @h[i]
        py = @max.to_a[j] - (y - 1) * @h[j]
        pz = @center.to_a[k]
        
        puts "\nProbe at (##px.round(4), ##py.round(4), ##pz.round(4))"
        puts "  F = ##@scalar1.interpolate(y, x).round(4)"
        puts "  Grad F = (##@vector1[1].interpolate(y, x).round(4), " +
              "##@vector1[2].interpolate(y, x).round(4), " +
              "##@vector1[3].interpolate(y, x).round(4))"
        puts "  Laplacian F = ##@scalar2.interpolate(y, x).round(4)"
      end
      
      # Cleanup
      def done
        @scalar1.free
        @scalar2.free
        @vector1.each(&:free)
      end
    end
    
    # Vector Field class
    class VectorField < ScalarField
      def initialize(size: 30)
        super
        @vector2 = Array.new(3) # DMatrix.new(size, size) 
        @equation = ["", "", ""]
      end
      
      def read_function
        puts "\n=== Vector Field Input ==="
        puts "Enter Ax function:"
        print "Ax > "
        @equation[0] = gets&.strip || ""
        puts "Enter Ay function:"
        print "Ay > "
        @equation[1] = gets&.strip || ""
        puts "Enter Az function:"
        print "Az > "
        @equation[2] = gets&.strip || ""
        
        @active = !@equation.all?(&:empty?)
        find_field if @active
        @active
      end
      
      def find_field
        return unless @active
        
        # Create matrices for each component
        3.times do |comp|
          parser = Parser.new
          parser.set_real_variable('theta', 0) if @coordinates == 3
          parser.set_real_variable('rho', 0) if @coordinates == 3
          parser.set_real_variable('phi', 0) if @coordinates > 1
          
          xyz = ['x', 'y', 'z']
          i, j, k = get_plane_indices
          
          ok = parser.parse(xyz[i], xyz[j], xyz[k], 'r', @equation[comp])
          
          if ok
            create_component_matrix(parser, comp)
          end
        end
        
        find_div_curl
        draw_plots
      end
      
      def create_component_matrix(parser, comp)
        i, j, k = get_plane_indices
        
        (1..@size).each do |row|
          (1..@size).each do |col|
            x = @min.to_a[i] + (col - 1) * @h[i]
            y = @max.to_a[j] - (row - 1) * @h[j]
            z = @center.to_a[k]
            
            value = evaluate_with_coords(parser, x, y, z, i, j, k)
            @vector1[comp + 1].put(row, col, value)
          end
        end
      end
      
      def find_div_curl
        wait = GUI::WaitMessage.new
        wait.show
        
        i, j, k = get_plane_indices
        
        (1..@size).each do |row|
          (1..@size).each do |col|
            x = @min.to_a[i] + (col - 1) * @h[i]
            y = @max.to_a[j] - (row - 1) * @h[j]
            z1 = @center.to_a[k] - @h[k]
            z2 = @center.to_a[k] + @h[k]
            
            # Divergence: dAx/dx + dAy/dy + dAz/dz
            div = @vector1[i].dmdx(row, col, @h[i]) +
                  (-@vector1[j].dmdy(row, col, @h[j]))
            @scalar1.put(row, col, div)
            
            # Curl components
            # (Curl A)_i = dAz/dy - dAy/dz
            dAy_dz = (@vector1[2].value(row, col + 1) - @vector1[2].value(row, col - 1)) / (2 * @h[k])
            dAz_dy = -(@vector1[3].dmdy(row, col, @h[j]))
            @vector2[i].put(row, col, dAz_dy - dAy_dz)
            
            # (Curl A)_j = dAx/dz - dAz/dx
            dAx_dz = (@vector1[1].value(row, col + 1) - @vector1[1].value(row, col - 1)) / (2 * @h[k])
            dAz_dx = @vector1[3].dmdx(row, col, @h[i])
            @vector2[j].put(row, col, dAx_dz - dAz_dx)
            
            # (Curl A)_k = dAy/dx - dAx/dy
            dAy_dx = @vector1[2].dmdx(row, col, @h[i])
            dAx_dy = -@vector1[1].dmdy(row, col, @h[j])
            @vector2[k].put(row, col, dAy_dx - dAx_dy)
          end
          wait.update
        end
        
        wait.hide
      end
      
      def done
        super
        @vector2.each(&:free)
      end
    end
    
    # Main Fields simulation controller
    class Fields
      attr_reader :scalar_field, :vector_field, :current_field
      
      def initialize
        @scalar_field = ScalarField.new
        @vector_field = VectorField.new
        @current_field = @scalar_field
        @quit_flag = false
      end
      
      def run
        show_about
        
        loop do
          show_menu
          break if @quit_flag
          
          handle_choice(gets&.strip)
        end
      end
      
      def show_about
        puts "\n" + "=" * 60
        puts "    Scalar and Vector Fields"
        puts "    Written by Jarek Tuszynski"
        puts "    George Mason University"
        puts "    (c) 1995, John Wiley & Sons"
        puts "=" * 60
        puts "\nFIELDS allows you to explore the behavior of arbitrary"
        puts "scalar or vector field when operated on by various"
        puts "differential operators and when integrated along arbitrary paths."
        puts "\nPress Enter to continue..."
        gets
      end
      
      def show_menu
        puts "\n=== Fields Simulation Menu ==="
        puts "1. Read Scalar Field"
        puts "2. Read Vector Field"
        puts "3. Grid Size"
        puts "4. Choose Plane"
        puts "5. Choose Graphs"
        puts "6. Mouse Probe"
        puts "7. Path Integral"
        puts "8. Help"
        puts "9. Exit"
        print "Select: "
      end
      
      def handle_choice(choice)
        case choice
        when "1"
          @current_field = @scalar_field
          @scalar_field.read_function
        when "2"
          @current_field = @vector_field
          @vector_field.read_function
        when "3"
          resize_grid
        when "4"
          choose_plane
        when "5"
          @current_field.choose_graphs
        when "6"
          enable_probe
        when "7"
          path_integral
        when "8"
          show_help
        when "9"
          @quit_flag = true
        end
      end
      
      def resize_grid
        print "Enter grid size (10-80): "
        size = gets&.strip.to_i
        if size >= 10 && size <= 80
          @scalar_field.resize(size, size)
          @vector_field.resize(size, size)
          puts "Grid resized to ##sizex##size"
        else
          puts "Invalid size. Must be between 10 and 80."
        end
      end
      
      def choose_plane
        puts "\nChoose Plane:"
        puts "1. yz-plane (x = constant)"
        puts "2. zx-plane (y = constant)"
        puts "3. xy-plane (z = constant)"
        print "Select: "
        plane = gets&.strip.to_i
        print "Enter value: "
        val = gets&.strip.to_f
        
        @scalar_field.define_plane(plane, val)
        @vector_field.define_plane(plane, val)
      end
      
      def enable_probe
        @scalar_field.probe = true
        @vector_field.probe = true
        puts "Probe enabled. Click on the plot area."
        
        # Demo probe
        @scalar_field.field_probe(@scalar_field.size / 2, @scalar_field.size / 2)
      end
      
      def path_integral
        puts "\nPath Integral - Coming soon"
        puts "(This feature requires the integral visualization module)"
      end
      
      def show_help
        puts "\n=== Help ==="
        puts "Menu Options:"
        puts " - File: About CUPS, About Program, Configuration, Exit"
        puts " - Field: Read Scalar/Vector Field, Grid Size, Choose Plane"
        puts " - Graphs: Choose Graphs, Mouse Probe, Path Integral"
        puts "\nPress Enter to continue..."
        gets
      end
      
      def finish
        @scalar_field.done
        @vector_field.done
      end
    end
  end
end