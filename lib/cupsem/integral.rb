#************************************
#************************************
#***    Module Integral (CUPS)    ***
#***  Written by Jarek Tuszynski  ***
#***        January 1993          ***
#***      Ruby Port (2024)        ***
#************************************
#************************************
module CUPSem
  module Integral
    class << self
      #-------------------------- Simpson Integration --------------
      def simpson(f, a, b, n = 100)
        return 0 if n < 2 || n.odd?
        h = (b - a) / n
        sum = f[a] + f[b]
        (1...n).each do |i|
          coeff = i.even? ? 2 : 4
          sum += coeff * f[a + i * h]
        end
        sum * h / 3.0
      end
      
      #-------------------------- Trapezoidal Rule -----------------
      def trapezoidal(f, a, b, n = 100)
        h = (b - a) / n
        sum = (f[a] + f[b]) / 2.0
        (1...n).each do |i|
          sum += f[a + i * h]
        end
        sum * h
      end
      
      #-------------------------- Gaussian Quadrature -------------
      def gaussian(f, a, b)
        nodes = [
          -0.906179845938664,
          -0.538469310105683,
          0.0,
          0.538469310105683,
          0.906179845938664
        ]
        weights = [
          0.236926885056189,
          0.478628670499366,
          0.568888888888889,
          0.478628670499366,
          0.236926885056189
        ]
        m = (b + a) / 2.0
        h = (b - a) / 2.0
        sum = 0
        nodes.each_with_index do |node, i|
          sum += weights[i] * f[m + h * node]
        end
        sum * h
      end
      
      #-------------------------- Adaptive Simpson ----------------
      def adaptive_simpson(f, a, b, tol = 1e-6, max_depth = 20)
        adaptive_simpson_rec(f, a, b, tol, f[a], f[b], f[(a+b)/2], max_depth)
      end
      
      private
      
      def adaptive_simpson_rec(f, a, b, tol, fa, fb, fc, depth)
        c = (a + b) / 2
        fd = f[c]
        left = simpson_simple(f, a, c, fa, fd, fc)
        right = simpson_simple(f, c, b, fc, fd, fb)
        whole = simpson_simple(f, a, b, fa, fb, fc)
        if depth <= 0 || (left + right - whole).abs <= 15 * tol
          return left + right + (left + right - whole) / 15.0
        end
        left_val = adaptive_simpson_rec(f, a, c, tol / 2, fa, fc, fd, depth - 1)
        right_val = adaptive_simpson_rec(f, c, b, tol / 2, fc, fb, fd, depth - 1)
        left_val + right_val
      end
      
      def simpson_simple(f, a, b, fa, fm, fb)
        (b - a) * (fa + 4 * fm + fb) / 6.0
      end
    end
  end
  
  #-------------------------- Derivatives --------------------------
  module Derivative
    class << self
      #-------------------------- Central Difference --------------
      def central(f, x, h = 1e-8)
        (f[x + h] - f[x - h]) / (2 * h)
      end
      
      #-------------------------- Forward Difference -------------
      def forward(f, x, h = 1e-8)
        (f[x + h] - f[x]) / h
      end
      
      def backward(f, x, h = 1e-8)
        (f[x] - f[x - h]) / h
      end
      
      #-------------------------- Second Derivative --------------
      def second(f, x, h = 1e-8)
        (f[x + h] - 2 * f[x] + f[x - h]) / (h * h)
      end
    end
  end
  
  #-------------------------- Root Finding -----------------------
  module RootFinding
    class << self
      #-------------------------- Bisection Method ----------------
      def bisection(f, a, b, tol = 1e-10, max_iter = 100)
        fa, fb = f[a], f[b]
        return nil if fa * fb > 0
        (1..max_iter).each do
          c = (a + b) / 2
          fc = f[c]
          return c if (b - a) < tol || fc.abs < tol
          if fa * fc < 0
            b = c
            fb = fc
          else
            a = c
            fa = fc
          end
        end
        (a + b) / 2
      end
      
      #-------------------------- Newton-Raphson Method ----------
      def newton(f, df, x0, tol = 1e-10, max_iter = 50)
        x = x0
        max_iter.times do
          fx = f[x]
          return x if fx.abs < tol
          dfx = df[x]
          return nil if dfx.abs < 1e-15
          x_new = x - fx / dfx
          return x_new if (x_new - x).abs < tol
          x = x_new
        end
        x
      end
      
      #-------------------------- Secant Method ------------------
      def secant(f, x0, x1, tol = 1e-10, max_iter = 50)
        (1..max_iter).each do
          fx0, fx1 = f[x0], f[x1]
          return nil if (fx1 - fx0).abs < 1e-15
          x2 = x1 - fx1 * (x1 - x0) / (fx1 - fx0)
          return x2 if (x2 - x1).abs < tol
          x0, x1 = x1, x2
        end
        x1
      end
    end
  end
  
  #-------------------------- Interpolation ----------------------
  module Interpolation
    class << self
      #-------------------------- Linear Interpolation -----------
      def linear(x, x0, y0, x1, y1)
        return y0 if x1 == x0
        y0 + (y1 - y0) * (x - x0) / (x1 - x0)
      end
      
      #-------------------------- Bilinear Interpolation ---------
      def bilinear(x, y, grid)
        i = [0, [grid.n_cols - 2, (x - 1).to_i].min].max
        j = [0, [grid.n_rows - 2, (y - 1).to_i].min].max
        f00 = grid.value(j + 1, i + 1)
        f10 = grid.value(j + 1, i + 2)
        f01 = grid.value(j + 2, i + 1)
        f11 = grid.value(j + 2, i + 2)
        tx = x - i - 1
        ty = y - j - 1
        (1 - tx) * (1 - ty) * f00 +
          tx * (1 - ty) * f10 +
          (1 - tx) * ty * f01 +
          tx * ty * f11
      end
      
      #-------------------------- Cubic Spline#--------------------
      def cubic_spline(x, y, x_interp)
        n = x.size
        return y if n < 2
        h = Array.new(n - 1)
        (0...n - 1).each # |i| h[i] = x[i + 1] - x[i] 
        alpha = Array.new(n - 1)
        (1...n - 1).each do |i|
          alpha[i] = 3.0 * (y[i + 1] - y[i]) / h[i] -
                     3.0 * (y[i] - y[i - 1]) / h[i - 1]
        end
        y_interp = x_interp.map do |xi|
          i = (0...n - 1).find # |j| x[j] <= xi && xi <= x[j + 1] 
          next y[0] unless i
          t = (xi - x[i]) / h[i]
          (1 - t) * y[i] + t * y[i + 1]
        end
        y_interp
      end
    end
  end
end