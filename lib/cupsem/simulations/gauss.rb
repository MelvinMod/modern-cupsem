#************************************
#************************************
#***      Module GAUSS (CUPS)     ***
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
    #-------------------------- Gauss' Law Simulation ------------
    # Gauss' Law simulation - calculates charge density, potential, and electric field
    # for symmetric cases (spherical, cylindrical, planar)
    class Gauss
      attr_reader :symmetry, :initial_func, :max_r, :num_points
      attr_accessor :quit_request, :drawing
      
      # Symmetry types
      SPHERICAL = :spherical
      CYLINDRICAL = :cylindrical
      RECTANGULAR = :rectangular
      
      # Input function types
      CHARGE = :charge
      POTENTIAL = :potential
      FIELD = :field
      COMPARISON = :comparison
      
      def initialize
        @symmetry = SPHERICAL
        @initial_func = CHARGE
        @quit_request = false
        @drawing = false
        
        # Function strings
        @q_string = 'h(2-r)'  # Heaviside-like: charge within r=2
        @v_string = ''
        @e_string = ''
        @f_string = ''
        
        @max_r = 10.0
        @num_points = 200
        
        @parser = Parser.new
        @plots_3d = false
      end
      
      #-------------------------- Main Loop ----------------------
      def run
        setup_menu
        
        loop do
          check_events
          break if @quit_request
        end
        
        CUPSem.done
      end
      
      def setup_menu
        puts "\n=== Gauss' Law Simulation ==="
        puts "Calculating Charge Density, Potential and Electric Field"
        puts "in Symmetric Cases"
        puts "=" * 50
      end
      
      #-------------------------- Input Function ------------------
      def input_function_screen
        puts "\n=== Input Function ==="
        
        case @symmetry
        when SPHERICAL
          coord = 'r'
          puts "(Spherical Symmetry)"
        when CYLINDRICAL
          coord = 'r'
          puts "(Cylindrical Symmetry)"
        when RECTANGULAR
          coord = 'x'
          puts "(Planar Symmetry)"
        end
        
        case @initial_func
        when CHARGE
          prompt = "Rho(##coord)="
        when POTENTIAL
          prompt = "V(##coord)="
        when FIELD
          prompt = "E(##coord)="
        when COMPARISON
          prompt = "F(##coord)="
        end
        
        print "##prompt "
        func_str = gets&.strip
        
        return false if func_str.nil? || func_str.empty?
        
        # Store based on type
        case @initial_func
        when CHARGE then @q_string = func_str
        when POTENTIAL then @v_string = func_str
        when FIELD then @e_string = func_str
        when COMPARISON then @f_string = func_str
        end
        
        print "Range of ##coord from 0 to: "
        @max_r = gets&.strip.to_f
        
        # Parse the function
        @parser.parse('r', 'x', 'r', 'r', func_str)
      end
      
      # Draw the three functions (Q, V, E)
      def draw_3_functions
        # Create vectors
        x = DVector.new(@num_points)
        q = DVector.new(@num_points)
        v = DVector.new(@num_points)
        e = DVector.new(@num_points)
        
        wait = GUI::WaitMessage.new
        wait.show
        
        # Evaluate function at each point
        (1..@num_points).each do |r|
          radius = (r - 1) * @max_r / (@num_points - 1)
          x.put(r, radius)
          
          value = @parser.f(radius, radius, 0, 0)
          
          # Cap extreme values
          value = 1e6 if value > 1e6
          value = -1e6 if value < -1e6
          
          q.put(r, value)
        end
        
        # Handle edge case
        if (q.value(1) - 1e6).abs < 1
          q.put(1, 3*q.value(2) - 3*q.value(3) + q.value(4))
        end
        
        wait.hide
        
        # Calculate related functions based on input type
        case @initial_func
        when CHARGE
          find_e_v(q, e, v)
        when POTENTIAL
          v.equate(1, q)
          find_e_q(v, e, q)
        when FIELD
          e.equate(1, q)
          find_v_q(e, v, q)
        end
        
        # Plot results
        plot_results(x, q, v, e)
        
        # Draw charge distribution cloud
        draw_cloud(q)
        
        #-------------------------- Cleanup -----------------------
        q.free
        v.free
        e.free
        x.free
      end
      
      # Find E and V from Q (charge density)
      def find_e_v(q, e, v)
        y = DVector.new(@num_points)
        
        case @symmetry
        when SPHERICAL
          # E = (1/r²) ∫ρr²dr
          (1..@num_points).each do |r|
            radius = (r - 1.0)
            y.put(r, q.value(r) * radius * radius)
          end
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              e.put(r, y.simpson(1, r) / (radius * radius))
            end
          end
          
        when CYLINDRICAL
          # E = (1/r) ∫ρr dr
          (1..@num_points).each do |r|
            radius = (r - 1.0)
            y.put(r, q.value(r) * radius)
          end
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              e.put(r, y.simpson(1, r) / radius)
            end
          end
          
        when RECTANGULAR
          # E = ∫ρ dx
          (1..@num_points).each do |r|
            e.put(r, q.simpson(1, r))
          end
          e.add_scalar(-e.value(@num_points) / 2)
        end
        
        # Handle edge (r=0)
        if @symmetry != RECTANGULAR
          e.put(1, 3*e.value(2) - 3*e.value(3) + e.value(4))
        end
        
        y.free
        
        #-------------------------- Find E and V from Q ----------
        # V = -∫E dr
        (1..@num_points).each do |r|
          v.put(r, -e.simpson(1, r))
        end
      end
      
      #-------------------------- Find E and Q from V ------------
      def find_e_q(v, e, q)
        y = DVector.new(@num_points)
        
        case @symmetry
        when SPHERICAL
          # Q = (1/r²) d/dr (r² dV/dr)
          (1..@num_points).each do |r|
            radius = (r - 1.0)
            y.put(r, v.value(r) * radius)
          end
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              q.put(r, y.dVdx(r, 1) / (radius * radius))
            end
          end
          
        when CYLINDRICAL
          # Q = (1/r) d/dr (r dV/dr)
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              q.put(r, v.dVdx(r, 1) / radius)
            end
          end
          
        when RECTANGULAR
          # Q = dV/dx
          (1..@num_points).each do |r|
            y.put(r, v.value(r) / r)
          end
          (1..@num_points).each do |r|
            q.put(r, y.dVdx(r, 1))
          end
        end
        
        y.free
        
        # Handle edge
        if @symmetry != RECTANGULAR
          q.put(1, 3*q.value(2) - 3*q.value(3) + q.value(4))
        end
        
        # E = -dV/dx
        (1..@num_points).each do |r|
          e.put(r, -v.dVdx(r, 1))
        end
      end
      
      #-------------------------- Find V and Q from E ------------
      def find_v_q(e, v, q)
        y = DVector.new(@num_points)
        
        case @symmetry
        when SPHERICAL
          # Q = r² dE/dr + 2rE
          (1..@num_points).each do |r|
            radius = (r - 1.0)
            y.put(r, e.value(r) * radius * radius)
          end
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              q.put(r, y.dVdx(r, 1) / (radius * radius))
            end
          end
          
        when CYLINDRICAL
          # Q = r dE/dr + E
          (1..@num_points).each do |r|
            radius = (r - 1.0)
            y.put(r, e.value(r) * radius)
          end
          (2..@num_points).each do |r|
            radius = (r - 1.0)
            if radius > 0
              q.put(r, y.dVdx(r, 1) / radius)
            end
          end
          
        when RECTANGULAR
          # Q = dE/dx
          (1..@num_points).each do |r|
            q.put(r, e.dVdx(r, 1))
          end
        end
        
        y.free
        
        # Handle edge
        if @symmetry != RECTANGULAR
          q.put(1, 3*q.value(2) - 3*q.value(3) + q.value(4))
        end
        
        # V = -∫E dr
        (1..@num_points).each do |r|
          v.put(r, -e.simpson(1, r))
        end
      end
      
      # Plot results
      def plot_results(x, q, v, e)
        puts "\n" + "=" * 50
        puts "Results:"
        puts "=" * 50
        
        # Find scale
        scale_results(q, v, e)
        
        # Print summary
        puts "\nCharge Density (Q):"
        puts "  Min: ##q.min_max[0].round(4)"
        puts "  Max: ##q.min_max[1].round(4)"
        
        puts "\nPotential (V):"
        puts "  Min: ##v.min_max[0].round(4)"
        puts "  Max: ##v.min_max[1].round(4)"
        
        puts "\nElectric Field (E):"
        puts "  Min: ##e.min_max[0].round(4)"
        puts "  Max: ##e.min_max[1].round(4)"
        
        # Sample values
        puts "\nSample values at r = 0, 2, 4, 6, 8, 10:"
        sample_indices = [1, @num_points * 0.2, @num_points * 0.4, 
                          @num_points * 0.6, @num_points * 0.8, @num_points]
        
        puts "r       Q           V           E"
        sample_indices.each do |idx|
          r_val = x.value(idx).round(2)
          q_val = q.value(idx).round(4)
          v_val = v.value(idx).round(4)
          e_val = e.value(idx).round(4)
          puts "##r_val.to_s.ljust(5) ##q_val.to_s.ljust(10) ##v_val.to_s.ljust(10) ##e_val"
        end
        
        @drawing = true
      end
      
      #-------------------------- Scale Results ------------------
      def scale_results(q, v, e)
        # Scale y-axes
        min1, max1 = q.min_max
        min2, max2 = v.min_max
        min3, max3 = e.min_max
        
        # Adjust for display
      end
      
      # Draw charge distribution as point cloud
      def draw_cloud(q)
        puts "\nDrawing charge distribution..."
        
        q.min_max.each_with_index do |val, idx|
          next if val.nil?
          
          intensity = (val.abs / (@max_r * 10)).clamp(0, 1)
          char = val >= 0 ? '+' : '-'
          
          # Print simplified visualization
          if idx % 10 == 0
            print "##char"
          end
        end
        puts "\n(Charge cloud visualization)"
      end
      
      #-------------------------- Handle Menu#--------------------
      def handle_menu(col, row)
        case col
        when 1  # File
          case row
          when 1 then about_cups
          when 2 then about_program
          when 3 then configuration
          when 5 then @quit_request = true
          end
        when 2  # Input
          case row
          when 1
            @initial_func = CHARGE
            if input_function_screen
              draw_3_functions
            end
          when 2
            @initial_func = POTENTIAL
            if input_function_screen
              draw_3_functions
            end
          when 3
            @initial_func = FIELD
            if input_function_screen
              draw_3_functions
            end
          when 4
            @initial_func = COMPARISON
            if input_function_screen
              draw_comparison
            end
          end
        when 3  # Symmetry
          case row
          when 1
            @symmetry = SPHERICAL
            draw_3_functions if !@q_string.empty?
          when 2
            @symmetry = CYLINDRICAL
            draw_3_functions if !@q_string.empty?
          when 3
            @symmetry = RECTANGULAR
            draw_3_functions if !@q_string.empty?
          end
        end
      end
      
      def draw_comparison
        puts "\nDrawing comparison function..."
        # Would overlay comparison function on existing plots
      end
      
      #-------------------------- About CUPS ---------------------
      def about_cups
        puts "\n=== About CUPS ==="
        puts "Consortium for Upper-level Physics Software"
        puts "(c) 1994 by John Wiley & Sons"
      end
      
      def about_program
        puts "\n=== About This Program ==="
        puts "Calculating Charge Density, Potential and"
        puts "Electric Field in Symmetric Cases"
        puts "\nWritten by Jarek Tuszynski"
        puts "George Mason University"
      end
      
      #-------------------------- Configuration ------------------
      def configuration
        puts "\n=== Configuration ==="
        puts "Settings:"
        puts "  Grid size: ##@num_points"
        puts "  Max R: ##@max_r"
        puts "  Symmetry: ##@symmetry"
      end
      
      #-------------------------- Check Events -------------------
      def check_events
        # In interactive mode, just wait for input
        print "\nCommand (1-File, 2-Input, 3-Symmetry, 0-Exit): "
        input = gets&.strip
        
        return unless input
        
        case input
        when "1"
          puts "File menu: 1-About CUPS, 2-About Program, 3-Config, 5-Exit"
        when "2"
          puts "Input: 1-Charge, 2-Potential, 3-Field, 4-Comparison"
          handle_menu(2, gets&.strip.to_i)
        when "3"
          puts "Symmetry: 1-Spherical, 2-Cylindrical, 3-Planar"
          handle_menu(3, gets&.strip.to_i)
        when "0"
          @quit_request = true
        end
      end
      
      #-------------------------- Hot Key Handling ---------------
      def handle_hotkey(key)
        case key
        when 1
          show_help_screen
        when 2
          @plots_3d = !@plots_3d
          draw_3_functions
        when 3
          # Menu
        end
      end
      
      #-------------------------- Show Help ----------------------
      def show_help_screen
        puts "\n=== Help ==="
        puts "To run the program:"
        puts "  - Choose coordinate system"
        puts "  - Input charge distribution, potential, or electric field function"
        puts "  - Compare the output with your calculations"
        puts "\nMenu:"
        puts "  - File: Information and exit"
        puts "  - Input: Input function type"
        puts "  - Symmetry: Choose symmetry type"
        puts "\nHot Keys:"
        puts "  - Help: This screen"
        puts "  - 2D/3D plot: Switch between 2D and 3D plots"
        puts "  - Menu: Activate menu"
      end
    end
  end
end