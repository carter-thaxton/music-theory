module MusicTheory
  class Scale

    attr_reader :name, :intervals, :root

    def initialize(intervals, name, root=nil)
      @intervals = intervals
      @name = name
      @root = root
    end

    def with_name(name)
      Scale.new(intervals, name, root)
    end

    def with_root(root)
      Scale.new(intervals, name, root)
    end

    def without_root
      Scale.new(intervals, name)
    end

    def interval(i)
      if i.respond_to? :each
        i.map{|j| interval(j)}
      else
        raise ArgumentError, "interval must be non-zero" if i == 0
        i += i < 0 ? 1 : -1
        zero_based_interval(i)
      end
    end

    def note(i)
      raise ArgumentError, "Cannot get note for scale without a root" unless root

      if i.respond_to? :each
        i.map{|j| interval(j) + root}
      else
        interval(i) + root
      end
    end

    alias notes note

    def zero_based_interval(i)
      d = i % length
      o = i / length
      result = intervals[d]
      result = result + Interval.octave(o) if o != 0
      result
    end

    def length
      intervals.length
    end

    def [](i)
      if root
        root + zero_based_interval(i)
      else
        zero_based_interval(i)
      end
    end

    def to_s
      if root && name
        "#{root} #{name}"
      elsif name
        name
      elsif root
        "#{name} [#{intervals_s}]"
      else
        "[#{intervals_s}]"
      end
    end

    def inspect
      to_s
    end

    def intervals_s
      if root
        intervals.map{|i| (root + i).to_s}.join(' ')
      else
        intervals.map(&:scale_shorthand).join(' ')
      end
    end

    def rotate(n=1, new_name=nil)
      basis = zero_based_interval(n)
      new_intervals = intervals.rotate(n).map{|i| (i - basis).modulo_octave}
      Scale.new(new_intervals, new_name || name, root)
    end

    def transpose(interval)
      raise ArgumentError, "Cannot transpose scale unless unless it has a root" unless root
      Scale.new(intervals, name, root + interval)
    end

    def +(interval)
      transpose(interval)
    end

    def -(interval)
      self + -interval
    end

    def ==(scale)
      return false unless scale.intervals == self.intervals
      if self.root && scale.root
        return false unless self.root == scale.root
      end
      true
    end

    class << self
      def parse(str, name=nil, root=nil)
        intervals = str.split.map {|i| Interval.parse(i, true) }
        new(intervals, name, root)
      end

      def major(root=nil)
        Scale.parse("1 2 3 4 5 6 7", "major", root)
      end

      def natural_minor(root=nil)
        Scale.parse("1 2 b3 4 5 b6 b7", "natural minor", root)
      end

      def harmonic_minor(root=nil)
        Scale.parse("1 2 b3 4 5 b6 7", "harmonic minor", root)
      end

      def dorian(root=nil)
        Scale.major(root).rotate(1, 'dorian')
      end

      def phrygian(root=nil)
        Scale.major(root).rotate(2, 'phrygian')
      end

      def lydian(root=nil)
        Scale.major(root).rotate(3, 'lydian')
      end

      def mixolydian(root=nil)
        Scale.major(root).rotate(4, 'mixolydian')
      end

      def dorian(root=nil)
        Scale.major(root).rotate(1, 'dorian')
      end

      alias aeolian natural_minor

      def locrian(root=nil)
        Scale.major(root).rotate(-1, 'locrian')
      end

      def alt(root=nil)
        Scale.parse("1 b2 #2 3 b5 b6 b7", "alt", root)
      end

      def major_pentatonic(root=nil)
        Scale.parse("1 2 3 5 6", "major pentatonic", root)
      end

      def minor_pentatonic(root=nil)
        Scale.parse("1 b3 4 5 b7", "minor pentatonic", root)
      end

      def diminished(root=nil)
        Scale.parse("1 2 b3 4 b5 b6 bb7 7", "diminished", root)
      end
    end

  end
end
