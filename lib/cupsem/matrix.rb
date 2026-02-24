#************************************
#************************************
#***      Module Matrix (CUPS)    ***
#***  Written by Jarek Tuszynski  ***
#***        January 1993          ***
#***    Ruby Port by MelvinSGjr   ***
#***            (2026)            ***
#************************************
#************************************
module CUPSem
   #-------------------------- Matrix Class --------------------------
   class DMatrix
      attr_reader :n_rows, :n_cols
   
      def initialize(rows = 0, cols = 0)
         @n_rows = rows
         @n_cols = cols
         if rows > 0 && cols > 0
            @data = Array.new(rows) # Array.new(cols, 0.0) 
         else
            @data = []
         end
      end
   
      def [](row, col)
         @data[row - 1, col - 1]
      end
   
      def []=(row, col, value)
         @data[row - 1, col - 1] = value.to_f
      end
   
      def get_size
         [@n_rows, @n_cols]
      end
   
      #-------------------------- Free Matrix ------------------------
      def free
         @data = nil
         @n_rows = 0
         @n_cols = 0
      end
   
      def fill(value)
         @data.fill(value.to_f)
         self
      end
   
      #-------------------------- Min/Max Values#--------------------
      def min_max(row_min, row_max, col_min, col_max)
         min_val = Float::INFINITY
         max_val = -Float::INFINITY
         (row_min..row_max).each do |r|
            (col_min..col_max).each do |c|
               val = @data[r - 1][c - 1]
               min_val = val if val < min_val
               max_val = val if val > max_val
            end
         end
         [min_val, max_val]
      end
   
      alias_method :minmax, :min_max
   
      def minmax
         min_max(1, @n_rows, 1, @n_cols)
      end
   
      #-------------------------- Interpolation ---------------------
      def interpolate(row, col)
         r = row.round
         c = col.round
         return 0 if r < 1 || r > @n_rows || c < 1 || c > @n_cols
         r = [1, [@n_rows, r].min].max
         c = [1, [@n_cols, c].min].max
         self[r, c]
      end
   
      #---------------------- Partial Derivatives -------------------
      def dmdx(row, col, h)
         return 0 if col < 2 || col > @n_cols - 1
         (value(row, col + 1) - value(row, col - 1)) / (2 * h)
      end
   
      def dmdy(row, col, h)
         return 0 if row < 2 || row > @n_rows - 1
         (value(row - 1, col) - value(row + 1, col)) / (2 * h)
      end
   
      def value(row, col)
         return 0 if row < 1 || row > @n_rows || col < 1 || col > @n_cols
         @data[row - 1][col - 1]
      end
   
      def put(row, col, value)
         return self if row < 1 || row > @n_rows || col < 1 || col > @n_cols
         @data[row - 1][col - 1] = value.to_f
         self
      end
   
      def transpose
         result = DMatrix.new(@n_cols, @n_rows)
         (1..@n_rows).each do |r|
            (1..@n_cols).each do |c|
               result.put(c, r, self[r, c])
            end
         end
         result
      end
   
      def *(other)
         if other.is_a?(DMatrix)
            result = DMatrix.new(@n_rows, other.n_cols)
            (1..@n_rows).each do |i|
               (1..other.n_cols).each do |j|
                  sum = 0.0
                  (1..@n_cols).each do |k|
                     sum += self[i, k] * other[k, j]
                  end
                  result.put(i, j, sum)
               end
            end
            result
         else
            result = DMatrix.new(@n_rows, @n_cols)
            (1..@n_rows).each do |r|
               (1..@n_cols).each do |c|
                  result.put(r, c, self[r, c] * other.to_f)
               end
            end
            result
         end
      end
   
      def +(other)
         result = DMatrix.new(@n_rows, @n_cols)
         (1..@n_rows).each do |r|
            (1..@n_cols).each do |c|
               result.put(r, c, self[r, c] + other[r, c])
            end
         end
         result
      end
   
      def -(other)
         result = DMatrix.new(@n_rows, @n_cols)
         (1..@n_rows).each do |r|
            (1..@n_cols).each do |c|
               result.put(r, c, self[r, c] - other[r, c])
            end
         end
         result
      end
   
      def to_a
         @data
      end
   
      def self.from_array(arr)
         mat = new(arr.size, arr[0]&.size || 0)
         arr.each_with_index do |row, i|
            row.each_with_index do |val, j|
               mat.put(i + 1, j + 1, val)
            end
         end
         mat
      end
   end
   
   #-------------------------- Vector Class --------------------------
   class DVector
      attr_reader :size
   
      def initialize(size = 0)
         @size = size
         @data = size > 0 ? Array.new(size, 0.0) : []
      end
   
      def [](idx)
         @data[idx - 1] || 0.0
      end
   
      def []=(idx, value)
         @data[idx - 1] = value.to_f
      end
   
      alias_method :value, :[]
      alias_method :put, :[]=
   
      def free
         @data = nil
         @size = 0
      end
   
      def fill(value)
         @data.fill(value.to_f)
         self
      end
   
      #-------------------------- Min/Max ---------------------------
      def min_max
         return [0, 0] if @data.empty?
         [@data.min, @data.max]
      end
   
      #-------------------------- Simpson Integration ---------------
      def simpson(i, j)
         n = j - i + 1
         return 0 if n < 2
         n = n + 1 if n.odd?
         h = 1.0
         sum = self[i] + self[j]
         (1...(n - 1)).each do |k|
            coeff = k.even? ? 2 : 4
            sum += coeff * self[i + k]
         end
         sum * h / 3.0
      end
   
      #-------------------------- Derivative -------------------------
      def dVdx(i, h = 1)
         return 0 if i < 2 || i > @size - 1
         (value(i + 1) - value(i - 1)) / (2 * h)
      end
   
      #-------------------------- Add Scalar ------------------------
      def add_scalar(s)
         @data = @data.map # |x| x + s 
         self
      end
   
      #-------------------------- Equate ----------------------------
      def equate(start_idx, source)
         if source.is_a?(DVector)
            (@size - start_idx + 1).times do |i|
               @data[start_idx + i - 1] = source[i + 1] || 0.0
            end
         else
            @data.fill(source.to_f)
         end
         self
      end
   
      #-------------------------- Absolute Value#--------------------
      def abs
         result = DVector.new(@size)
         @data.each_with_index do |val, idx|
            result[idx + 1] = val.abs
         end
         result
      end
   
      #-------------------------- Length -----------------------------
      def length
         @size
      end
   
      def to_a
         @data.dup
      end
   
      def self.from_array(arr)
         vec = new(arr.size)
         arr.each_with_index do |val, idx|
            vec[idx + 1] = val
         end
         vec
      end
   end
   
   #-------------------------- 3D Point ----------------------------
   Point3D = Struct.new(:x, :y, :z) do
      def self.set(arr)
         new(arr[0] || 0, arr[1] || 0, arr[2] || 0)
      end
   
      def to_a
         [x, y, z]
      end
   end
   
   #-------------------------- 2D Point ----------------------------
   Point = Struct.new(:x, :y)
end