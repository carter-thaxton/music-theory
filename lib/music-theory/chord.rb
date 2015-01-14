module MusicTheory
  class Chord

    attr_reader :intervals, :root, :bass

    def initialize(intervals, root=nil, bass=nil)
      # normalize all intervals and use 9, 11, 13 when appropriate
      intervals = intervals.compact.map(&:modulo_octave)

      has_3 = intervals.any? {|i| i.number == 3}
      has_4 = intervals.any? {|i| i.number == 4}
      has_6 = intervals.any? {|i| i.number == 6}
      has_7_or_higher = intervals.any? {|i| i.number >= 7}

      intervals = intervals.map do |i|
        add_octave = case i.number
          when 2 then has_3 || has_4 || has_6 || has_7_or_higher
          when 4 then has_3 && (has_6 || has_7_or_higher)
          when 6 then has_7_or_higher
        end

        if add_octave
          i + Interval.octave
        else
          i
        end
      end

      root = root.without_octave if root.is_a?(Note) && root.octave

      @intervals = intervals.sort_by {|i| [i.number, i.offset]}
      @root = root

      if bass
        bass = bass - root if bass.is_a?(Note) && root.is_a?(Note)
        bass = bass.modulo_octave
      end
      @bass = bass || Interval.unison
    end

    def length
      intervals.length
    end

    def with_root(root)
      Chord.new(intervals, root, bass)
    end

    def with_bass(bass)
      Chord.new(intervals, root, bass)
    end

    alias over with_bass

    def transpose_root(interval)
      new_intervals = intervals.map {|i| i - interval}
      new_root = root && (root + interval)
      Chord.new(new_intervals, new_root, bass)
    end

    def reinterpret_root(new_root)
      if root
        transpose_root(new_root - root)
      else
        with_root(new_root)
      end
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

    def bass_note
      raise ArgumentError, "Cannot get bass note of a chord without a root note" unless root_note?
      root + bass
    end

    def root_note?
      root && root.is_a?(Note)
    end

    def root_interval?
      root && root.is_a?(Interval)
    end

    def rootless?
      !interval(1)
    end

    def seventh?
      !!interval(7)
    end

    def sixth?
      s = interval(6)
      !seventh? && s && s.major?
    end

    def major?
      quality == :major
    end

    def minor?
      quality == :minor
    end

    def augmented?
      quality == :augmented
    end

    def diminished?
      quality == :diminished
    end

    def suspended?
      quality == :suspended
    end

    def dominant?
      major? && interval(7) == Interval.minor(7)
    end

    def quality
      second = interval(2)
      third = interval(3)
      fourth = interval(4)
      fifth = interval(5)

      if third && fifth
        return :major if third.major? && fifth.perfect?
        return :augmented if third.major? && fifth.augmented?
        return :diminished if third.minor? && fifth.diminished?
        return :minor if third.minor?
      elsif third
        return :major if third.major?
        return :minor if third.minor?
      elsif second || fourth
        return :suspended
      elsif fifth
        return :augmented if fifth.augmented?
        return :diminished if fifth.diminished?
        return :power if fifth.perfect?
      end
    end

    def highest_extension
      if seventh?
        [13, 11, 9, 7].each do |i|
          int = interval(i)
          return i if int && ((i == 7) || int.perfect? || int.major?)
        end
      end
      nil
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

    def flat(i, n=1)
      # special case for b9.  Don't replace #9
      if i == 9
        ninth = interval(9)
        if ninth && ninth.augmented?
          return add Interval.major(9).flat(n)
        end
      end

      alter(i) {|interval| interval.flat(n) }
    end

    def sharp(i, n=1)
      # special case for #9.  Don't replace b9
      if i == 9
        ninth = interval(9)
        if ninth && (ninth.minor? or ninth.diminished?)
          return add Interval.major(9).sharp(n)
        end
      end

      alter(i) {|interval| interval.sharp(n) }
    end

    def ==(chord)
      return false unless chord.is_a? Chord
      return false unless intervals == chord.intervals
      if root && chord.root
        return false unless root == chord.root
      end
      true
    end

    def to_s
      seventh = interval(7)

      minor_s = root_interval? ? '' : 'm'

      quality_s = case quality
        when :major then ''
        when :minor then minor_s
        when :augmented then seventh? ? '' : '+'
        when :suspended then ''
        when :power then '5'
        when :diminished
          if seventh && seventh.minor?
            if root_interval?
              'ø'
            else
              minor_s
            end
          else
            'º'
          end
      end

      extension_s = if seventh
        if seventh.major? then '∆' + (highest_extension && highest_extension > 7 ? highest_extension.to_s : '')
        elsif seventh.minor? then highest_extension.to_s unless (highest_extension == 7 && quality_s == 'ø')
        elsif seventh.diminished? then 'b' * (seventh.quality_count - (diminished? ? 1 : 0)) + '7'
        elsif seventh.augmented? then '#' * seventh.quality_count + '7'
        end
      elsif sixth?
        '6'
      end

      modifiers_s = ''
      intervals.each do |interval|
        n = interval.number

        if n == 5
          ignore_fifth = ['º', 'ø', '+'].include?(quality_s) || interval.perfect?
        end

        unless [1, 3, 7].include?(n) || ignore_fifth
          if interval.major? or interval.perfect?
            if n == 2 || n == 4
              if quality == :suspended
                modifiers_s << 'sus' + interval.scale_shorthand
              else
                modifiers_s << 'add' + interval.scale_shorthand
              end
            elsif n == 6
              modifiers_s << 'add6' unless extension_s == '6'
            elsif n == 9 && extension_s == '6'
              modifiers_s << '9'  # special case for 69, instead of 6add9
            elsif n > (highest_extension || 0)
              modifiers_s << 'add' + interval.scale_shorthand
            end
          else
            modifiers_s << interval.scale_shorthand
          end
        end
      end

      if ['b5b9#9b13', 'b9#9b13', '#9b13', 'b9b13', 'b5b9#9'].include? modifiers_s
        modifiers_s = 'alt'
      end

      result = "#{quality_s}#{extension_s}#{modifiers_s}"
      result = "maj#{result}" if /\A[b#]/.match(result)
      result = "maj" if result.empty? && !root && major?

      "#{root_s}#{result}#{bass_s}"
    end

    def inspect
      to_s
    end

    def inversion
      case bass.number
        when 1 then 0
        when 3 then 1
        when 5 then 2
        when 7 then 3
      end
    end

    def figured_bass
      case inversion
        when 1 then seventh? ? '65' : '6'
        when 2 then seventh? ? '43' : '64'
        when 3 then '42'
      end
    end

    def root_s
      if root_interval?
        root.roman_numeral(quality)
      else
        root.to_s
      end
    end

    def bass_s
      unless bass.unison?
        s = if root_note?
          (root + bass).to_s
        else
          figured_bass || bass.shorthand
        end
        "/#{s}"
      end
    end

    def intervals_s
      intervals.map(&:scale_shorthand).join(' ')
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

      def suspended(root=nil)
        Chord.new([Interval.unison, Interval.perfect(4), Interval.perfect(5)], root)
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
          ((?:(?:\#|b|add|sus|Add|Sus|M|maj|Maj|alt)\d*)*)    # modifiers, e.g. b5sus4
          (?:\/(?:
            ([a-gA-G][sb#]*)|                                 # bass of chord, e.g. Ab
            (\d+)                                             # or figured bass notation
          ))?
          \s*
        \Z/x

        m = regex.match(str)
        raise ArgumentError, "Cannot parse #{str.inspect} as a chord" unless m
        root_note = m[1] && Note.parse(m[1])
        root_interval = m[2] && Interval.parse(m[2])
        root_interval_minor = root_interval && m[2].downcase == m[2]
        quality_s = m[3]
        extension = m[4] && m[4].to_i
        modifiers = m[5].scan(/(?:\#|b|add|sus|Add|Sus|M|maj|Maj|alt)\d*/)
        bass_note = m[6] && Note.parse(m[6])
        bass_interval_s = m[7]

        quality = :major
        seventh = 'b7'
        extension_modifiers = []

        quality = :minor if root_interval_minor

        case quality_s
        when 'M', 'maj', 'Maj', '∆'
          quality = :major
          seventh = 'M7'
          extension_modifiers << seventh if quality_s == '∆'
        when 'm', '-'
          quality = :minor
          seventh = 'b7'
        when 'aug', '+'
          quality = :augmented
          seventh = 'b7'
        when 'ø', 'Ø', '0'
          quality = :diminished
          seventh = 'b7'
          extension = 7 unless extension
        when 'dim', 'o', 'º'
          quality = :diminished
          seventh = 'bb7'
        end

        if extension
          case extension
          when 6
            extension_modifiers << 'add6'
          when 7
            extension_modifiers << seventh
          when 9
            extension_modifiers << seventh
            extension_modifiers << 'add9'
          when 11
            extension_modifiers << seventh
            extension_modifiers << 'add9'
            extension_modifiers << 'add11'
          when 13
            extension_modifiers << seventh
            extension_modifiers << 'add9'
            extension_modifiers << 'add11'
            extension_modifiers << 'add13'
          when 69
            extension_modifiers << 'add6'
            extension_modifiers << 'add9'
          else
            raise ArgumentError, "Invalid extension for chord: #{extension}"
          end
        end

        result = Chord.send(quality, root_note || root_interval)

        (extension_modifiers + modifiers).each do |modifier|
          m = /\A([a-zA-Z\#]+)(\d+)?\Z/.match modifier
          raise ArgumentError, "Invalid modifier for chord: #{modifier}" unless m

          type = m[1]
          number = m[2] && m[2].to_i

          case type
          when /\A\#+\Z/
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" unless number
            result = result.sharp(number, type.length)
          when /\Ab+\Z/
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" unless number
            result = result.flat(number, type.length)
          when 'add', 'Add'
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" unless number
            result = result.add(number)
          when 'sus', 'Sus'
            number ||= 4
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" unless [2, 4].include? number
            result = result.no(3).add(number)
          when 'M', 'maj', 'Maj'
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" if number && number != 7
            result = result.add('M7') unless result.seventh?
          when 'alt'
            raise ArgumentError, "Invalid modifier for chord: #{modifier}" if number
            result = result.flat(9).sharp(9).flat(5).flat(13)
            result = result.flat(7) unless result.seventh?
          else
            raise ArgumentError, "Invalid modifier for chord: #{modifier}"
          end
        end

        if bass_interval_s
          bass_interval_number = parse_figured_bass(bass_interval_s)
          bass_interval = result.interval(bass_interval_number)
          raise ArgumentError, "Figured bass #{bass_interval_s} does not refer to a note in the chord: #{result}" unless bass_interval
        end

        bass = bass_note || bass_interval
        result = result.over(bass) if bass

        result
      end

      def parse_intervals(str, root=nil)
        intervals = str.split.map{|s| Interval.parse(s, true)}
        new(intervals, root)
      end

      def from_notes(notes, root=notes.first)
        intervals = notes.map {|n| n - root}
        new(intervals, root)
      end

      def parse_figured_bass(str)
        s = str.to_s.gsub(/\D+/, '')
        case s
          when '7', '75', '753' then 1
          when '6', '65', '653' then 3
          when '64', '643', '43' then 5
          when '642', '42', '2' then 7
          else
            raise ArgumentError, "Cannot parse #{str} as figured bass"
        end
      end

    end
  end
end
