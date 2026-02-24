#************************************
#************************************
#***      Module Parser (CUPS)    ***
#***  Written by Jarek Tuszynski  ***
#***        January 1993          ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
require 'racc/parser'
require 'forwardable'

module CUPSem
  #-------------------------- Expression Parser#--------------------
  class Parser
    NUMERIC = /(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?/
    VARIABLE = /[a-zA-Z_][a-zA-Z0-9_]*/
    OPERATOR = /[\+\-\*\/\^\(\)]/
    
    FUNCTIONS = %w[
      sin cos tan cot sec csc
      asin acos atan atan2
      sinh cosh tanh sech csch coth
      asinh acosh atanh
      sqrt abs log log10 ln exp
      sgn sign floor ceil round
      pi e
    ].freeze
    
    VARIABLES = %w[x y z r rho theta phi].freeze
    
    #-------------------------- Initialization ---------------------
    attr_reader :variables, :error_message, :canceled
    
    def initialize
      @variables = #
      @error_message = nil
      @canceled = false
      @compiled = nil
    end
    
    #-------------------------- Set Variable -----------------------
    def set_real_variable(name, value)
      @variables[name.to_s] = value.to_f
    end
    
    #-------------------------- Parse Expression -------------------
    def parse(x_var, y_var, z_var, r_var, expression)
      @error_message = nil
      @canceled = false
      var_map = #
      var_map['x'] = x_var if x_var
      var_map['y'] = y_var if y_var
      var_map['z'] = z_var if z_var
      var_map['r'] = r_var if r_var
      expr = preprocess_expression(expression)
      begin
        @compiled = compile_expression(expr, var_map.keys + @variables.keys)
        true
      rescue => e
        @error_message = e.message
        false
      end
    end
    
    def f(x = 0, y = 0, z = 0, r = 0)
      return 0 unless @compiled
      ctx = @variables.dup
      ctx['x'] = x
      ctx['y'] = y
      ctx['z'] = z
      ctx['r'] = r
      ctx['rho'] = Math.sqrt(x*x + y*y) if ctx.key?('rho')
      ctx['theta'] = Math.atan2(y, x) if ctx.key?('theta')
      ctx['phi'] = Math.atan2(y, x) if ctx.key?('phi')
      begin
        @compiled.call(ctx)
      rescue => e
        @error_message = e.message
        0
      end
    end
    
    #-------------------------- Evaluate ---------------------------
    def evaluate(expression, x: 0, y: 0, z: 0, r: 0)
      parse('x', 'y', 'z', 'r', expression)
      f(x, y, z, r)
    end
    
    private
    
    def preprocess_expression(expr)
      result = expr.dup
      result.gsub!(/(\d)([a-zA-Z])/, '\1*\2')
      result.gsub!(/(\))(\d)/, '\1*\2')
      result.gsub!(/(\))([a-zA-Z\(])/, '\1*\2')
      result.gsub!('^', '**')
      result.gsub!(/\bln\(/, 'Math.log(')
      result.gsub!(/\blog10\(/, 'Math.log10(')
      result.gsub!(/\blog\b/, 'Math.log')
      result.gsub!(/\bsqrt\(/, 'Math.sqrt(')
      result.gsub!(/\babs\(/, 'Math.abs(')
      result.gsub!(/\bexp\(/, 'Math.exp(')
      result.gsub!(/\bsin\(/, 'Math.sin(')
      result.gsub!(/\bcos\(/, 'Math.cos(')
      result.gsub!(/\btan\(/, 'Math.tan(')
      result.gsub!(/\basin\(/, 'Math.asin(')
      result.gsub!(/\bacos\(/, 'Math.acos(')
      result.gsub!(/\batan\(/, 'Math.atan(')
      result.gsub!(/\batan2\(/, 'Math.atan2(')
      result.gsub!(/\bsinh\(/, 'CUPSem::Math.sinh(')
      result.gsub!(/\bcosh\(/, 'CUPSem::Math.cosh(')
      result.gsub!(/\btanh\(/, 'CUPSem::Math.tanh(')
      result.gsub!(/\bsech\(/, 'CUPSem::Math.sech(')
      result.gsub!(/\bcsch\(/, 'CUPSem::Math.csch(')
      result.gsub!(/\bcoth\(/, 'CUPSem::Math.coth(')
      result.gsub!(/\bpi\b/i, 'Math::PI')
      result.gsub!(/\be\b(?![x])/, 'Math::E')
      result.gsub!(/\bsgn\(/, 'CUPSem::Math.sgn(')
      result.gsub!(/\bsign\(/, 'CUPSem::Math.sign(')
      result
    end
    
    def compile_expression(expr, var_names)
      allowed_vars = (var_names + VARIABLES).uniq
      lambda do |ctx|
        x = ctx['x'] || 0
        y = ctx['y'] || 0
        z = ctx['z'] || 0
        r = ctx['r'] || Math.sqrt(x*x + y*y + z*z)
        eval(expr, binding)
      end
    end
  end
  
  #-------------------------- Simple Parser -----------------------
  #-------------------------- Simple Parser -----------------------
  class SimpleParser
    #-------------------------- Initialization ---------------------
    attr_reader :error_message
    
    def initialize
      @x = @y = @z = @r = 0
      @theta = @rho = 0
      @error_message = nil
    end
    
    def set_real_variable(name, value)
      case name.to_s
      when 'x' then @x = value
      when 'y' then @y = value
      when 'z' then @z = value
      when 'r' then @r = value
      when 'theta' then @theta = value
      when 'rho' then @rho = value
      when 'phi' then @phi = value
      end
    end
    
    def parse(x_var, y_var, z_var, r_var, expression)
      @expression = preprocess(expression)
      @error_message = nil
      true
    rescue => e
      @error_message = e.message
      false
    end
    
    def f(x = 0, y = 0, z = 0, r = 0)
      return 0 unless @expression
      @x = x
      @y = y
      @z = z
      @r = r
      @rho = Math.sqrt(x*x + y*y)
      @theta = Math.atan2(y, x)
      @phi = @theta
      begin
        eval(@expression)
      rescue => e
        @error_message = e.message
        0
      end
    end
    
    private
    
    def preprocess(expr)
      result = expr.dup
      result.gsub!('^', '**')
      {
        'ln(' => 'Math.log(',
        'log10(' => 'Math.log10(',
        'log(' => 'Math.log(',
        'sqrt(' => 'Math.sqrt(',
        'sin(' => 'Math.sin(',
        'cos(' => 'Math.cos(',
        'tan(' => 'Math.tan(',
        'asin(' => 'Math.asin(',
        'acos(' => 'Math.acos(',
        'atan(' => 'Math.atan(',
        'atan2(' => 'Math.atan2(',
        'exp(' => 'Math.exp(',
        'abs(' => 'Math.abs(',
        'pi' => 'Math::PI',
        'e' => 'Math::E'
      }.each { |k, v| result.gsub!(k, v) }
      result
    end
  end
end