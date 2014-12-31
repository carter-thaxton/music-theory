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
        root + interval(i)
      else
        interval(i)
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

    def rotate(n=1)
      basis = interval(n)
      new_intervals = intervals.rotate(n).map{|i| (i - basis).modulo_octave}
      Scale.new(new_intervals, name, root)
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

      def alt(root=nil)
        Scale.parse("1 b2 #2 3 b5 b6 b7", "alt", root)
      end

      def major_pentatonic(root=nil)
        Scale.parse("1 2 3 5 6", "major pentatonic", root)
      end

      def minor_pentatonic(root=nil)
        Scale.parse("1 b3 4 5 b7", "minor pentatonic", root)
      end
    end

  end
end
