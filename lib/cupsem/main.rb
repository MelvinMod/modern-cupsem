#************************************
#************************************
#***        CUPSem Main Menu      ***
#***  Written by Jarek Tuszynski  ***
#***       January 3, 1993        ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
require_relative '../cupsem'
require_relative 'simulations'
require_relative 'simulations/fields'
require_relative 'simulations/gauss'

module CUPSem
  #-------------------------- Application Class ------------------
  class Application
    PROGRAMS = [
      { id: 1, name: "Scalar and Vector Fields", dir: "Fields", class: Simulations::Fields },
      { id: 2, name: "Gauss' Law in Symmetric Cases", dir: "Gauss", class: Simulations::Gauss },
      { id: 3, name: "Calculations of Potential using Poisson's Eqn", dir: "Poisson", class: Simulations::Poisson },
      { id: 4, name: "Image Charges and the Multipole Expansion", dir: "Imag&Mul", class: Simulations::ImagMul },
      { id: 5, name: "Atomic Polarization", dir: "AtomPol", class: Simulations::AtomPol },
      { id: 6, name: "Dielectric Media", dir: "Dielect", class: Simulations::Dielect },
      { id: 7, name: "Magnetostatics", dir: "MagStat", class: Simulations::MagStat },
      { id: 8, name: "Animated Electric Field of a Moving Charge", dir: "QAnimate", class: Simulations::QAnimate },
      { id: 9, name: "Electromagnetic Fields of a Moving Charge", dir: "AccelQ", class: Simulations::AccelQ },
      { id: 10, name: "Electromagnetic Plane Waves", dir: "EMwave", class: Simulations::EMWave },
      { id: 11, name: "Exit the Program", exit: true }
    ].freeze
    
    def initialize
      @exit_request = false
      @choice = 1
    end
    
    #-------------------------- Show Menu ------------------------
    def show_menu
      puts "\n" + "=" * 70
      puts "          Electricity & Magnetism"
      puts "              Simulations"
      puts "=" * 70
      puts "                    CUPS"
      puts "     (Consortium of Upper-level Physics Software)"
      puts "=" * 70
      puts

      PROGRAMS.each do |prog|
        if prog[:exit]
          puts "  #{prog[:id].to_s.ljust(2)}: #{prog[:name]}"
        else
          puts "  #{prog[:id].to_s.ljust(2)}: #{prog[:name]}"
        end
      end
      
      puts
      print "Enter your choice (1-11): "
    end
    
    #-------------------------- Get Choice -----------------------
    def get_choice
      input = gets
      return 11 if input.nil? || input.strip.empty?
      
      choice = input.strip.to_i
      choice = 1 if choice < 1 || choice > 11
      choice
    end
    
    #-------------------------- Run Program ----------------------
    def run_program(choice)
      prog = PROGRAMS.find { |p| p[:id] == choice }
      return unless prog
      
      if prog[:exit]
        @exit_request = true
        return
      end
      
      puts "\n" + "=" * 50
      puts "Loading: #{prog[:name]}"
      puts "=" * 50
      
      begin
        simulation = prog[:class].new
        simulation.run if simulation.respond_to?(:run)
      rescue => e
        puts "Error running simulation: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
    end
    
    #-------------------------- Main Loop ------------------------
    def run
      puts "\n" + "=" * 70
      puts "  CUPSem - Ruby Port of CUPS Physics Simulations"
      puts "  Original: (c) 1994 by John Wiley & Sons"
      puts "  Port: MIT License"
      puts "=" * 70
      puts "\nPress Enter to continue..."
      gets
      
      until @exit_request
        show_menu
        @choice = get_choice
        puts "\n"
        run_program(@choice)
      end
      
      puts "\nThank you for using CUPSem!"
      puts "Exiting..."
    end
    
    #-------------------------- About ----------------------------
    def about
      puts <<~ABOUT
        CUPSem - Ruby Port
        ==================
        
        This is a Ruby port of the CUPS (Consortium of Upper-level 
        Physics Software) electricity and magnetism simulations.
        
        Original Pascal code written by:
        - Jarek Tuszynski (George Mason University)
        - William M. MacDonald (University of Maryland)
        
        Original (c) 1994 by John Wiley & Sons
        
        This Ruby port is distributed under the MIT License.
        
        Supported simulations:
        - Scalar and Vector Fields
        - Gauss' Law
        - Poisson's Equation
        - Image Charges and Multipole Expansion
        - Atomic Polarization
        - Dielectric Media
        - Magnetostatics
        - Moving Charge Animation
        - EM Fields of Accelerated Charge
        - Electromagnetic Plane Waves
      ABOUT
    end
  end
end

# Run the application
if __FILE__ == $0
  app = CUPSem::Application.new
  
  # Check for command line arguments
  if ARGV.include?('--about') || ARGV.include?('-a')
    app.about
  elsif ARGV.include?('--help') || ARGV.include?('-h')
    puts "Usage: ruby main.rb [options]"
    puts "  --about, -a    Show about information"
    puts "  --help, -h     Show this help"
    puts "  --fields       Run Fields simulation"
    puts "  --gauss        Run Gauss' Law simulation"
  elsif ARGV.include?('--fields')
    sim = CUPSem::Simulations::Fields.new
    sim.run
  elsif ARGV.include?('--gauss')
    sim = CUPSem::Simulations::Gauss.new
    sim.run
  else
    app.run
  end
end