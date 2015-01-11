module MusicTheory
  class Chord

    attr_reader :intervals, :root

    def initialize(intervals, root=nil)
      @intervals = intervals.compact.sort_by &:number
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

    def seventh?
      !!interval(7)
    end

    def quality
      third = interval(3)
      fourth = interval(4)
      fifth = interval(5)

      if third && fifth
        return :major if third.major? && fifth.perfect?
        return :minor if third.minor? && fifth.perfect?
        return :augmented if third.major? && fifth.augmented?
        return :diminished if third.minor? && fifth.diminished?
      elsif third
        return :major if third.major?
        return :minor if third.minor?
      elsif fourth
        return :suspended
      elsif fifth
        return :augmented if fifth.augmented?
        return :diminished if fifth.diminished?
      end
    end

    def dominant?
      quality == :major && interval(7) == Interval.minor(7)
    end

    def alter(n)
      existing_interval = interval(n)
      if existing_interval
        new_interval = yield existing_interval
      else
        new_interval = yield Interval.parse(n, true)
      end

      new_intervals = intervals.clone
      new_intervals.delete(existing_interval) if existing_interval
      new_intervals << new_interval

      Chord.new(new_intervals, root)
    end

    def no(n)
      new_intervals = intervals.clone

      if n.is_a? Interval
        new_intervals.delete_if {|i| i == n}
      else
        existing_interval = interval(n)
        new_intervals.delete(existing_interval) if existing_interval
      end

      Chord.new(new_intervals, root)
    end

    def add(interval)
      interval = Interval.parse(interval, true) unless interval.is_a? Interval

      new_intervals = intervals.clone
      new_intervals << interval

      Chord.new(new_intervals, root)
    end

    def flat(n)
      alter(n) {|i| i.flat }
    end

    def sharp(n)
      alter(n) {|i| i.sharp}
    end

    def ==(chord)
      return false unless chord.is_a? Chord
      return false unless intervals == chord.intervals
      if root && chord.root
        return false unless root == chord.root
      end
      true
    end

    class << self

      def major(root=nil)
        Chord.new([Interval.unison, Interval.major(3), Interval.perfect(5)], root)
      end

      def minor(root=nil)
        Chord.new([Interval.unison, Interval.minor(3), Interval.perfect(5)], root)
      end

      def augmented(root=nil)
        Chord.new([Interval.unison, Interval.major(3), Interval.augmented(5)], root)
      end

      def diminished(root=nil)
        Chord.new([Interval.unison, Interval.minor(3), Interval.diminished(5)], root)
      end

      def dominant(root=nil)
        Chord.new([Interval.unison, Interval.major(3), Interval.perfect(5), Interval.minor(7)], root)
      end

      def parse(str)
        regex = /\A
          \s*                                                 # ignore leading whitespace
          (?:
            ([a-gA-G][sb#]*)|                                 # root of chord, e.g. Ab
            ([sb#]*[ivIV]+)                                   # or roman numeral of chord, e.g. bVII
          )?
          (M|maj|Maj|∆|m|min|\-|\+|aug|0|ø|o|º|dim)?          # quality, e.g. maj
          (\d+)?                                              # extension, e.g. 7
          ((?:(?:s|\#|b|add|sus|Add|Sus|M|maj|Maj|alt)\d*)*)  # modifiers, e.g. b5sus4
          \s*
        \Z/x

        m = regex.match(str)
        raise ArgumentError, "Cannot parse #{str.inspect} as a chord" unless m
        root_note = m[1] && Note.parse(m[1])
        root_interval = m[2] && Interval.parse(m[2])
        root_interval_minor = root_interval && m[2].downcase == m[2]
        quality_s = m[3]
        extension = m[4] && m[4].to_i
        modifiers = m[5].scan(/(?:s|\#|b|add|sus|Add|Sus|M|maj|Maj|alt)\d*/)

        quality = :major
        seventh = 'b7'

        quality = :minor if root_interval_minor

        case quality_s
        when 'M', 'maj', 'Maj', '∆'
          quality = :major
          seventh = 'M7'
        when 'm', '-'
          quality = :minor
          seventh = 'b7'
        when 'aug', '+'
          quality = :augmented
          seventh = 'b7'
        when 'ø', 'Ø', '0'
          quality = :half_diminished
          seventh = 'b7'
        when 'dim', 'o', 'º'
          quality = :diminished
          seventh = 'bb7'
        end

        if extension
          case extension
          when 6
            modifiers << 'add6'
          when 7
            modifiers << seventh
          when 9
            modifiers << seventh
            modifiers << 'add9'
          when 11
            modifiers << seventh
            modifiers << 'add9'
            modifiers << 'add11'
          when 13
            modifiers << seventh
            modifiers << 'add9'
            modifiers << 'add11'
            modifiers << 'add13'
          when 69
            modifiers << 'add6'
            modifiers << 'add9'
          else
            raise ArgumentError, "Invalid extension for chord: #{extension}"
          end
        end

        d = { root_note: root_note, root_interval: root_interval, quality: quality, extension: extension, modifiers: modifiers, root_interval_minor: root_interval_minor }
        puts d

        Chord.new([Interval.unison, Interval.major(3), Interval.perfect(5)], root_note || root_interval)
      end
    end
  end
end
