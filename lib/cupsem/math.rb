=begin
*************************************
*************************************
***      Module Math (CUPS)      ***
***  Written by Jarek Tuszynski  ***
***        January 1993          ***
***    Ruby Port by MelvinSGjr   ***
***            (2026)            ***
*************************************
*************************************
=end
require 'complex'

module CUPSem
  module Math
    class << self
      include Math
      
      #-------------------------- Power Function#--------------------
      def pwr(x, y)
        n = y.to_i
        if n != y
          if x < 0
            error("Pwr(x,y): undefined for x<0 for y not an integer")
            return nil
          end
          return 0 if x == 0
          Math.exp(y * Math.log(x))
        else
          negpwr = (n < 0)
          n = n.abs
          temp = 1.0
          while n > 0
            temp *= x if n.odd?
            x = x * x
            n >>= 1
          end
          negpwr ? 1.0 / temp : temp
        end
      end
      
      #-------------------------- Trigonometric Functions -----------
      def tan(x)
        c = Math.cos(x)
        if c == 0
          error("Tan(x): infinite for x = pi/2 + n*pi")
          return nil
        end
        Math.sin(x) / c
      end
      
      def csc(x)
        s = Math.sin(x)
        if s == 0
          error("Csc: infinite for x=n*pi")
          return nil
        end
        1.0 / s
      end
      
      def sec(x)
        c = Math.cos(x)
        if c == 0
          error("Sec: infinite for x = pi/2 + n*pi")
          return nil
        end
        1.0 / c
      end
      
      def cot(x)
        s = Math.sin(x)
        if s == 0
          error("Cot(x): infinite for x = n*pi")
          return nil
        end
        Math.cos(x) / s
      end
      
      #-------------------------- Inverse Trig Functions ------------
      def arc_sin(x)
        if x.abs > 1.0
          error("ArcSin(x): undefined for |x| >1")
          return nil
        end
        return Math::PI / 2.0 if x == 1
        return -Math::PI / 2.0 if x == -1
        Math.atan(x / Math.sqrt(1.0 - x * x))
      end
      
      def arc_cos(x)
        if x.abs > 1.0
          error("ArcCos(x): not defined for |x| > 1")
          return nil
        end
        return Math::PI / 2.0 if x == 0
        if x < 0
          Math.atan(Math.sqrt(1.0 - x * x) / x) + Math::PI
        else
          Math.atan(Math.sqrt(1.0 - x * x) / x)
        end
      end
      
      def arc_tan2(x, y)
        if x == 0
          return 0 if y == 0
          return Math::PI - sgn(y) * Math::PI / 2.0
        end
        if x > 0
          return Math.atan(y / x) if y >= 0
          return Math.atan(y / x) + 2.0 * Math::PI
        end
        Math.atan(y / x) + Math::PI
      end
      
      #-------------------------- Trigonometric Functions -----------
      def sin(x)
        Math.sin(x)
      end
      
      def cos(x)
        Math.cos(x)
      end
      
      def tan(x)
        c = Math.cos(x)
        if c == 0
          error("Tan(x): infinite for x = pi/2 + n*pi")
          return nil
        end
        Math.sin(x) / c
      end
      
      def csc(x)
        s = Math.sin(x)
        if s == 0
          error("Csc: infinite for x=n*pi")
          return nil
        end
        1.0 / s
      end
      
      def sec(x)
        c = Math.cos(x)
        if c == 0
          error("Sec: infinite for x = pi/2 + n*pi")
          return nil
        end
        1.0 / c
      end
      
      def cot(x)
        s = Math.sin(x)
        if s == 0
          error("Cot(x): infinite for x = n*pi")
          return nil
        end
        Math.cos(x) / s
      end
      
      #-------------------------- Hyperbolic Functions -------------
      def sinh(x)
        (Math.exp(x) - Math.exp(-x)) / 2.0
      end
      
      def cosh(x)
        (Math.exp(x) + Math.exp(-x)) / 2.0
      end
      
      def tanh(x)
        if x.abs < -Math.log(machine_eps)
          temp = Math.exp(2.0 * x)
          (temp - 1) / (temp + 1)
        elsif x > 0
          1
        else
          -1
        end
      end
      
      def sech(x)
        if x.abs < 50
          z = Math.exp(x)
          2.0 / (z + 1.0 / z)
        else
          z = x.abs / Math.log(10)
          n = z.to_i
          f = Math.exp((z - n) * Math.log(10))
          recexp = 1.0 / f
          p = 0.1
          while n > 0
            recexp *= p if n.odd?
            p *= p
            n >>= 1
          end
          2.0 * recexp / (1.0 + recexp * recexp)
        end
      end
      
      def csch(x)
        if x == 0.0
          error("Csch: infinite for x = 0")
          return nil
        elsif x.abs < 50
          z = Math.exp(x)
          2.0 / (z - 1.0 / z)
        else
          z = x.abs / Math.log(10)
          n = z.to_i
          f = Math.exp((z - n) * Math.log(10))
          recexp = 1.0 / f
          p = 0.1
          while n > 0
            recexp *= p if n.odd?
            p *= p
            n >>= 1
          end
          if x > 0
            2.0 * recexp / (1.0 - recexp * recexp)
          else
            -2.0 * recexp / (1.0 - recexp * recexp)
          end
        end
      end
      
      def coth(x)
        if x.abs < -Math.log(machine_eps)
          temp = Math.exp(2.0 * x)
          if temp != 1.0
            (temp + 1) / (temp - 1)
          else
            error("Coth: infinite for x = 0")
            nil
          end
        elsif x > 0
          1
        else
          -1
        end
      end
      
      #-------------------------- Inverse Hyperbolic Functions ------
      def arc_sinh(x)
        Math.log(x + Math.sqrt(x * x + 1.0))
      end
      
      def arc_cosh(x)
        if x >= 1.0
          Math.log(x + Math.sqrt(x * x - 1.0))
        else
          error("ArcCosh(x): complex value for x < 1")
          nil
        end
      end
      
      def arc_tanh(x)
        if x.abs < 1.0
          Math.log((1.0 + x) / (1.0 - x)) / 2.0
        else
          error("ArcTanh(x): undefined for Abs(x)>= 1")
          nil
        end
      end
      
      #-------------------------- Logarithm Functions ---------------
      def log_base(x, y)
        if x < 0 || y < 0 || x == 1.0
          error("Log(x,y): undefined for x<0 or y<0 or x=1")
          nil
        else
          Math.log(y) / Math.log(x)
        end
      end
      
      def log10(y)
        if y <= 0
          error("Log10(y): undefined for y<=0")
          nil
        else
          Math.log(y) / Math.log(10)
        end
      end
      
      #-------------------------- Sign Functions#--------------------
      def sgn(y)
        return 1 if y > 0
        return 0 if y == 0
        -1
      end
      
      def sign(x, y)
        y < 0 ? -x.abs : x.abs
      end
      
      #-------------------------- Machine Epsilon -------------------
      def machine_eps
        @machine_eps ||= calculate_machine_eps
      end
      
      def calculate_machine_eps
        macheps = 1.0
        while (macheps + 1.0) == 1.0
          macheps /= 2
        end
        macheps
      end
      
      private
      
      #-------------------------- Error Handling#--------------------
      def error(str)
        puts "Error: ##str"
      end
    end
  end
  
  #-------------------------- Complex Math --------------------------
  module ComplexMath
    class ComplexNumber < ::Complex
      def self.add(z1, z2)
        Complex.new(z1.real + z2.real, z1.imag + z2.imag)
      end
      
      def self.subtract(z1, z2)
        Complex.new(z1.real - z2.real, z1.imag - z2.imag)
      end
      
      def self.multiply(z1, z2)
        Complex.new(
          z1.real * z2.real - z1.imag * z2.imag,
          z1.real * z2.imag + z1.imag * z2.real
        )
      end
      
      def self.divide(z1, z2)
        if z2.real == 0 && z2.imag == 0
          raise "ComplexMath: attempted division by zero"
        end
        
        if z2.real > z2.imag
          r = z2.imag / z2.real
          den = z2.real + z2.imag * r
          Complex.new(
            (z1.real + z1.imag * r) / den,
            (z1.imag - z1.real * r) / den
          )
        else
          r = z2.real / z2.imag
          den = z2.real * r + z2.imag
          Complex.new(
            (z1.real * r + z1.imag) / den,
            (z1.imag * r - z1.real) / den
          )
        end
      end
      
      def self.power(z, y)
        l = complex_log(z)
        amp = Math.exp(y.real * l.real - y.imag * l.imag)
        den = y.imag * l.real + y.real * l.imag
        Complex.new(amp * Math.cos(den), amp * Math.sin(den))
      end
      
      def self.complex_log(z)
        zabs = Math.sqrt(z.real**2 + z.imag**2)
        if zabs == 0
          raise "ComplexMath: infinite when z has magnitude zero"
        end
        Complex.new(Math.log(zabs), argument(z))
      end
      
      def self.abs(z)
        if z.real > z.imag
          z.real.abs * Math.sqrt(1 + (z.imag.to_f / z.real)**2)
        else
          z.imag.abs * Math.sqrt(1 + (z.real.to_f / z.imag)**2)
        end
      end
      
      def self.argument(z)
        return sgn(z.imag) * Math::PI / 2 if z.real == 0
        a = Math.atan(z.imag / z.real)
        if z.real < 0
          z.imag >= 0 ? a + Math::PI : a - Math::PI
        else
          a
        end
      end
      
      def self.exp(z)
        s = Math.exp(z.real)
        Complex.new(s * Math.cos(z.imag), s * Math.sin(z.imag))
      end
      
      def self.sin(z)
        e = Math.exp(z.imag)
        Complex.new(
          Math.sin(z.real) * (e + 1.0 / e) / 2,
          Math.cos(z.real) * (e - 1.0 / e) / 2
        )
      end
      
      def self.cos(z)
        e = Math.exp(z.imag)
        Complex.new(
          Math.cos(z.real) * (e + 1.0 / e) / 2,
          -Math.sin(z.real) * (e - 1.0 / e) / 2
        )
      end
      
      def self.tan(z)
        Complex.new(
          Math.sin(2.0 * z.real) / (Math.cos(2.0 * z.real) + cosh(z.imag)),
          sinh(2.0 * z.imag) / (Math.cos(2.0 * z.real) + cosh(2.0 * z.imag))
        )
      end
    end
  end
end