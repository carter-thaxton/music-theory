module MusicTheory
  class Chord

    attr_reader :intervals, :root

    def initialize(intervals, root=nil)
      @intervals = intervals
      @root = root
    end

    def length
      intervals.length
    end

    def notes
      raise ArgumentError, "Cannot get notes of a chord without a root" unless root
      intervals.map{|i| root + i}
    end

    def interval(n)
      intervals.find{|i| i.number == n}
    end

    def note(n)
      raise ArgumentError, "Cannot get note of a chord without a root" unless root
      i = interval(n)
      i && (root + i)
    end

    def quality
      :major
    end

    class << self
      def parse(str)
        m = /\A\s*([a-gA-G][sb#]*)?(.*)\s*\Z/.match(str)
        raise ArgumentError, "Cannot parse #{str.inspect} as a chord" unless m
        root = m[1] && Note.parse(m[1])
        c_str = m[2]


        Chord.new([Interval.unison, Interval.major(3), Interval.perfect(5)], root)
      end
    end
  end
end
