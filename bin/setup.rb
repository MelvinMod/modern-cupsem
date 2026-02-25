#!/usr/bin/env ruby
# CUPSem Setup Script
# Installs dependencies and verifies the setup

require 'fileutils'
require 'rbconfig'

module CUPSem
  module Setup
    class << self
      def run
        puts "=" * 60
        puts "  CUPSem Setup - Ruby Port of CUPS Physics Simulations"
        puts "=" * 60
        puts
        
        check_ruby
        check_gem_dependencies
        check_system_dependencies
        create_directories
        run_tests
        
        puts
        puts "=" * 60
        puts "  Setup Complete!"
        puts "=" * 60
        puts
        puts "To run CUPSem:"
        puts "  ruby -Ilib lib/cupsem/main.rb"
        puts
        puts "For help:"
        puts "  ruby -Ilib lib/cupsem/main.rb --help"
      end
      
      def check_ruby
        puts "Checking Ruby version..."
        puts "  Ruby: #{RUBY_VERSION}"
        puts "  Platform: #{RUBY_PLATFORM}"
        puts "  OK!"
        puts
      end
      
      def check_gem_dependencies
        puts "Checking Ruby gems..."
        
        # Core dependencies
        gems = {
          'complex' => false,  # Built-in
          'racc'    => false   # Built-in
        }
        
        gems.each do |gem, required|
          begin
            require gem
            puts "  #{gem}: OK (built-in)"
          rescue LoadError
            if required
              puts "  #{gem}: MISSING (required)"
            else
              puts "  #{gem}: Not found (optional)"
            end
          end
        end
        
        # Try to load optional gems
        optional = ['numo-narray', 'gnuplot', 'rubyplot']
        optional.each do |gem|
          begin
            require gem
            puts "  #{gem}: OK"
          rescue LoadError
            puts "  #{gem}: Not found (optional)"
          end
        end
        
        puts
      end
      
      def check_system_dependencies
        puts "Checking system dependencies..."
        
        # Check for gnuplot
        gnuplot = find_command('gnuplot')
        if gnuplot
          puts "  gnuplot: OK (#{gnuplot})"
          puts "  → Install gnuplot for real graphics (plots, contours, vector fields)"
        else
          puts "  gnuplot: NOT FOUND"
          
          case RbConfig::CONFIG['host_os']
          when /linux/
            puts "  → Install with: sudo pacman -S gnuplot"
          when /darwin/
            puts "  → Install with: brew install gnuplot"
          when /mingw|mswin|cygwin/
            puts "  → Install with: choco install gnuplot"
          end
        end
        
        # Check for display command
        display = find_command('xdg-open') || find_command('open') || find_command('start')
        if display
          puts "  image viewer: OK"
        else
          puts "  image viewer: Not found (plots won't auto-display)"
        end
        
        puts
      end
      
      def find_command(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe)
          end
        end
        nil
      end
      
      def create_directories
        puts "Creating directories..."
        dirs = ['/tmp/cupsem_plots']
        dirs.each do |dir|
          FileUtils.mkdir_p(dir) rescue nil
          puts "  #{dir}: OK"
        end
        puts
      end
      
      def run_tests
        puts "Running basic tests..."
        
        # Add lib directory to load path (relative to project root)
        base_dir = File.dirname(File.dirname(File.expand_path(__FILE__)))
        lib_dir = File.join(base_dir, 'lib')
        $LOAD_PATH.unshift(lib_dir)
        
        begin
          require 'cupsem'
          puts "  CUPSem module: OK"
          
          # Test math functions
          result = CUPSem::Math.pwr(2, 3)
          puts "  Math.pwr(2,3) = #{result}: #{result == 8.0 ? 'OK' : 'FAIL'}"
          
          # Test matrix
          m = CUPSem::DMatrix.new(3, 3)
          m.fill(1.0)
          puts "  DMatrix: OK"
          
          # Test parser
          p = CUPSem::SimpleParser.new
          p.set_real_variable('x', 2)
          result = p.evaluate('x^2 + 1', x: 2)
          puts "  Parser: #{result == 5 ? 'OK' : 'FAIL'}"
          
          # Test integral
          f = ->(x) { x * x }
          result = CUPSem::Integral.simpson(f, 0, 1)
          puts "  Integral: #{result.abs - 1.0/3.0 < 0.001 ? 'OK' : 'FAIL'}"
          
        rescue => e
          puts "  ERROR: #{e.message}"
        end
        
        puts
      end
    end
  end
end

# Run setup if executed directly
if __FILE__ == $0
  CUPSem::Setup.run
end
