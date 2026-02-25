# CUPSem Graphics Backend using Gnuplot
# This module provides visualization similar to original CUPS Pascal code
# Requires: gnuplot installed on system

module CUPSem
  module Graphics
    class << self
      attr_accessor :gnuplot_path, :use_png, :output_dir
      
      @gnuplot_path = 'gnuplot'
      @use_png = true
      @output_dir = '/tmp/cupsem_plots'
      
      def init
        require 'fileutils'
        FileUtils.mkdir_p(@output_dir)
        @initialized = true
      end
      
      # Check if gnuplot is available
      def gnuplot_available?
        system("#{@gnuplot_path} -V", out: File::NULL, err: File::NULL)
      end
      
      # Plot 2D function
      def plot_function(title, xlabel, ylabel, x_range, func, &block)
        init unless @initialized
        
        plot_file = "#{@output_dir}/plot_#{$$}.gnu"
        output_file = "#{@output_dir}/#{title.gsub(/\s+/, '_')}_#{$$}.png"
        
        File.open(plot_file, 'w') do |f|
          f.puts "set terminal png size 800,600"
          f.puts "set output '#{output_file}'"
          f.puts "set title '#{title}'"
          f.puts "set xlabel '#{xlabel}'"
          f.puts "set ylabel '#{ylabel}'"
          f.puts "set grid"
          f.puts "set xrange [#{x_range[0]}:#{x_range[1]}]" if x_range
          f.puts "plot '-' with lines title 'f(x)'"
          
          # Generate data points
          x = x_range ? x_range[0] : 0
          x_end = x_range ? x_range[1] : 10
          step = (x_end - x) / 100.0
          
          while x <= x_end
            y = block ? block.call(x) : func.call(x)
            f.puts "#{x} #{y}"
            x += step
          end
          f.puts "e"
        end
        
        system("#{@gnuplot_path} #{plot_file}")
        File.delete(plot_file) if File.exist?(plot_file)
        
        puts "Plot saved to: #{output_file}"
        output_file
      end
      
      # Plot 3D surface
      def plot_surface(title, xlabel, ylabel, zlabel, x_range, y_range, matrix)
        init unless @initialized
        
        plot_file = "#{@output_dir}/surface_#{$$}.gnu"
        output_file = "#{@output_dir}/#{title.gsub(/\s+/, '_')}_#{$$}.png"
        
        File.open(plot_file, 'w') do |f|
          f.puts "set terminal png size 800,600"
          f.puts "set output '#{output_file}'"
          f.puts "set title '#{title}'"
          f.puts "set xlabel '#{xlabel}'"
          f.puts "set ylabel '#{ylabel}'"
          f.puts "set zlabel '#{zlabel}'"
          f.puts "set hidden3d"
          f.puts "set contour base"
          f.puts "splot '-' with lines"
          
          # Output matrix data
          matrix.each do |row|
            row.each { |v| f.print "#{v} " }
            f.puts
          end
          f.puts "e"
        end
        
        system("#{@gnuplot_path} #{plot_file}")
        File.delete(plot_file) if File.exist?(plot_file)
        
        puts "Surface plot saved to: #{output_file}"
        output_file
      end
      
      # Plot contour
      def plot_contour(title, xlabel, ylabel, matrix, levels: 10)
        init unless @initialized
        
        plot_file = "#{@output_dir}/contour_#{$$}.gnu"
        output_file = "#{@output_dir}/#{title.gsub(/\s+/, '_')}_#{$$}.png"
        
        File.open(plot_file, 'w') do |f|
          f.puts "set terminal png size 800,600"
          f.puts "set output '#{output_file}'"
          f.puts "set title '#{title}'"
          f.puts "set view map"
          f.puts "set size square"
          f.puts "set cntrparam levels #{levels}"
          f.puts "splot '-' with lines"
          
          matrix.each do |row|
            row.each { |v| f.print "#{v} " }
            f.puts
          end
          f.puts "e"
        end
        
        system("#{@gnuplot_path} #{plot_file}")
        File.delete(plot_file) if File.exist?(plot_file)
        
        puts "Contour plot saved to: #{output_file}"
        output_file
      end
      
      # Vector field plot
      def plot_vector_field(title, ux, uy, x_range, y_range, scale: 1.0)
        init unless @initialized
        
        plot_file = "#{@output_dir}/vector_#{$$}.gnu"
        output_file = "#{@output_dir}/#{title.gsub(/\s+/, '_')}_#{$$}.png"
        
        File.open(plot_file, 'w') do |f|
          f.puts "set terminal png size 800,600"
          f.puts "set output '#{output_file}'"
          f.puts "set title '#{title}'"
          f.puts "set xrange [#{x_range[0]}:#{x_range[1]}]"
          f.puts "set yrange [#{y_range[0]}:#{y_range[1]}]"
          f.puts "set grid"
          f.puts "set size ratio -1"
          f.puts "plot '-' with vectors"
          
          ux.each_with_index do |_, i, j|
            x = x_range[0] + j * (x_range[1] - x_range[0]) / (ux[0].size - 1)
            y = y_range[0] + i * (y_range[1] - y_range[0]) / (ux.size - 1)
            dx = ux[i, j] * scale
            dy = uy[i, j] * scale
            f.puts "#{x} #{y} #{dx} #{dy}"
          end
          f.puts "e"
        end
        
        system("#{@gnuplot_path} #{plot_file}")
        File.delete(plot_file) if File.exist?(plot_file)
        
        puts "Vector field saved to: #{output_file}"
        output_file
      end
      
      # Display plot (Linux)
      def display(file)
        case RUBY_PLATFORM
        when /linux/
          system("xdg-open #{file} 2>/dev/null &")
        when /darwin/
          system("open #{file}")
        when /mingw|mswin/
          system("start #{file}")
        end
      end
      
      # Open interactive gnuplot session
      def interactive
        puts "Starting interactive Gnuplot..."
        puts "Type 'exit' to quit"
        exec("#{@gnuplot_path} -persist")
      end
    end
  end
end
