module MusicTheory
  class Scale

    attr_reader :intervals, :root

    def initialize(intervals, root)
      @intervals = intervals
      @root = root
    end

    def [](i)
      intervals[i]
    end

    def length
      intervals.length
    end

    class << self
      def major(root=nil)
        #Scale.parse("1 2 3 4 5 6 7", root)
        Scale.new [Interval.unison, Interval.major(2), Interval.major(3), Interval.perfect(4), Interval.perfect(5), Interval.major(6), Interval.major(7)], root
      end

      def natural_minor(root=nil)
        #Scale.parse("1 2 b3 4 5 b6 b7", root)
        Scale.new [Interval.unison, Interval.major(2), Interval.minor(3), Interval.perfect(4), Interval.perfect(5), Interval.minor(6), Interval.minor(7)], root
      end

      def harmonic_minor(root=nil)
        Scale.new [Interval.unison, Interval.major(2), Interval.minor(3), Interval.perfect(4), Interval.perfect(5), Interval.minor(6), Interval.major(7)], root
      end

      def alt(root=nil)
        Scale.parse("1 b2 #2 3 b5 b6 b7", root)
      end
    end

  end
end
