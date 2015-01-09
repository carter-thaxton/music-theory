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
        regex = /\A
          \s*                                             # ignore leading whitespace
          (?:
            ([a-gA-G][sb#]*)|                             # root of chord, e.g. Ab
            ([sb#]*[ivIV]+)                               # or roman numeral of chord, e.g. bVII
          )?
          (M|maj|Maj|m|min|\-|\+|aug|0|ø|o|º|dim)?        # quality, e.g. maj
          (\d+)?                                          # number, e.g. 7
          ((?:(?:s|\#|b|add|sus|Add|Sus)\d+|alt)*)        # modifiers, e.g. #5b9
          \s*
        \Z/x

        m = regex.match(str)
        raise ArgumentError, "Cannot parse #{str.inspect} as a chord" unless m
        root_note = m[1] && Note.parse(m[1])
        root_interval = m[2] && Interval.parse(m[2])
        quality = m[3]
        number = m[4] && m[4].to_i
        modifiers = m[5].scan(/(?:s|\#|b|add|sus|Add|Sus)\d+|alt/)

        # handle 69 as a special case
        if number == 69
          number = nil
          modifiers << 'add6'
          modifiers << 'add9'
        end

        root_interval_minor = root_interval && m[2].downcase == m[2]

        d = { root_note: root_note, root_interval: root_interval, quality: quality, number: number, modifiers: modifiers, root_interval_minor: root_interval_minor }
        puts d

        Chord.new([Interval.unison, Interval.major(3), Interval.perfect(5)], root_note || root_interval)
      end
    end
  end
end
