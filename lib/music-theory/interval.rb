module MusicTheory
  class Interval

    attr_reader :number, :offset

    QUALITIES = [:perfect, :major, :minor, :augmented, :diminished]

    def initialize(number, offset=nil)
      @number = number.to_i
      raise ArgumentError, "number must be a non-zero integer" if @number == 0
      @generic = offset.nil?
      @offset = offset.to_i
    end

    def ==(interval)
      return false unless interval.is_a? Interval
      return false unless interval.number == self.number
      if interval.specific? && self.specific?
        return false unless interval.offset == self.offset
      end
      true
    end

    def eql?(other)
      return false unless self == other
      other.generic? == self.generic? && other.offset == self.offset
    end

    def hash
      [number, offset].hash
    end

    def semitones
      result = Interval.semitone_basis(simple_number)
      result += offset
      result = -result if down?
      result += octave_offset * 12
      result
    end

    def quality
      return nil if generic?

      if perfect_number?
        if offset == 0
          :perfect
        elsif offset > 0
          :augmented
        else
          :diminished
        end
      else
        if offset == 0
          :major
        elsif offset == -1
          :minor
        elsif offset > 0
          :augmented
        else
          :diminished
        end
      end
    end

    # if diminished or augmented, how diminished or augmented?
    # 0 for generic, major, minor, perfect
    def quality_count
      case quality
        when nil, :major, :minor, :perfect then 0
        when :diminished then -offset - (perfect_number? ? 0 : 1)
        when :augmented then offset
      end
    end

    def generic?
      @generic
    end

    def specific?
      !generic?
    end

    def simple?
      number.abs <= 7
    end

    def compound?
      !simple?
    end

    def down?
      number < 0
    end

    def up?
      !down?
    end

    def unison?
      number == 1 || number == -1
    end

    def unison_or_octave?
      simple_number == 1
    end

    alias octave_or_unison? unison_or_octave?

    def octave?
      unison_or_octave? and not unison?
    end

    def perfect?
      quality == :perfect
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

    def flat?
      offset < 0
    end

    def sharp?
      offset > 0
    end

    def perfect_number?
      Interval.perfect_number? number
    end

    def major_minor_number?
      Interval.major_minor_number? number
    end

    def to_s
      dir_s = "down " if down?
      if specific? and not (perfect? and unison_or_octave?)
        prefix = case quality_count
        when nil, 0, 1 then ''
        when 2 then 'double-'
        when 3 then 'triple-'
        else
          "#{quality_count}-"
        end
        quality_s = "#{prefix}#{quality} "
      end
      "#{dir_s}#{quality_s}#{ord_s}"
    end

    def shorthand
      quality_s = case quality
        when :perfect then 'P'
        when :major then 'M'
        when :minor then 'm'
        when :augmented then 'A' * quality_count
        when :diminished then 'd' * quality_count
      end

      s = number < 0 ? '-' : ''
      "#{s}#{quality_s}#{number.abs}"
    end

    def scale_shorthand
      quality_s = case quality
        when :perfect, :major then ''
        when :minor then 'b'
        when :augmented then '#' * quality_count
        when :diminished
          if perfect_number?
            'b' * quality_count
          else
            'b' * (quality_count + 1)
          end
      end

      prefix = '-' if down?
      "#{prefix}#{quality_s}#{number.abs}"
    end

    def roman_numeral(chord_quality=nil)
      return modulo_octave.roman_numeral(chord_quality) if compound? or down?

      numeral = case simple_number
        when 1 then 'I'
        when 2 then 'II'
        when 3 then 'III'
        when 4 then 'IV'
        when 5 then 'V'
        when 6 then 'VI'
        when 7 then 'VII'
      end

      minor_chord = case chord_quality
        when :major, :perfect, :augmented then false
        when :minor, :diminished then true
        else
          not (perfect_number? || minor? || diminished?)
      end

      numeral = numeral.downcase if minor_chord

      if specific?
        accidentals = modulo_octave.semitones - Interval.semitone_basis(number)
        if accidentals < 0
          accidentals_s = 'b' * -accidentals
        else
          accidentals_s = '#' * accidentals
        end
      end

      "#{accidentals_s}#{numeral}"
    end

    def simple
      Interval.new(signed_simple_number, offset)
    end

    def signed_simple_number
      down? ? -simple_number : simple_number
    end

    def simple_number
      Interval.simple_number(number)
    end

    def modulo_octave
      result = simple
      if result.down?
        result = result.inverse unless result.unison?
        result = result.abs
      end
      result
    end

    def diatonic_offset
      down? ? number + 1 : number - 1
    end

    def octave_offset
      s = down? ? -1 : 1
      ((number.abs - 1) / 7) * s
    end

    def inspect
      to_s
    end

    def augment(n=1)
      if n == 0
        self
      else
        Interval.new(number, offset + n)
      end
    end

    def diminish(n=1)
      augment(-n)
    end

    alias sharp augment
    alias augmented augment
    alias flat diminish
    alias diminished diminish

    def inverse
      if down?
        Interval.octave(-1) - self
      else
        Interval.octave(+1) - self
      end
    end

    def up
      down? ? -self : self
    end

    def down
      down? ? self : -self
    end

    alias abs up

    def +@
      self
    end

    def -@
      Interval.new(-number, offset)
    end

    def -(interval)
      self + -interval
    end

    def +(interval)
      return interval + self if interval.is_a? Note

      interval = Scale.major[interval] if interval.is_a? Fixnum

      n = interval.diatonic_offset + self.diatonic_offset
      o = (n < 0 || n == 0 && self.down?) ? -1 : 1
      new_number = n + o

      if self.generic? or interval.generic?
        Interval.new(new_number)
      else
        s = interval.semitones + self.semitones
        Interval.with_semitones(new_number, s)
      end
    end

    private

    def ord_s
      i = number.abs
      case i
      when 1 then "unison"
      when 2 then "2nd"
      when 3 then "3rd"
      else
        if (i - 1) % 7 == 0
          n = (i - 1) / 7
          if n == 1 then "octave" else "#{n} octaves" end
        elsif i > 20
          case i % 10
          when 1 then "#{i}st"
          when 2 then "#{i}st"
          when 3 then "#{i}rd"
          else
            "#{i}th"
          end
        else
          "#{i}th"
        end
      end
    end

    class << self
      def simple_number(n)
        (n.abs - 1) % 7 + 1
      end

      def perfect_number?(n)
        [1,4,5].include? simple_number(n)
      end

      def major_minor_number?(n)
        !perfect_number?(n)
      end

      def zero_based(n, offset=nil)
        number = n + (n < 0 ? -1 : 1)
        new(number, offset)
      end

      def generic(i)
        new(i)
      end

      def unison
        new(1, 0)
      end

      def octave(n=1)
        zero_based(7*n, 0)
      end

      def perfect(i)
        new(i, 0)
      end

      def major(i)
        new(i, 0)
      end

      def minor(i)
        offset = major_minor_number?(i) ? -1 : 0
        new(i, offset)
      end

      def natural(i)
        new(i, 0)
      end

      def sharp(i, n=1)
        new(i, n)
      end

      def flat(i, n=1)
        new(i, -n)
      end

      def augmented(i, a=1)
        new(i, a)
      end

      def diminished(i, d=1)
        d += 1 if major_minor_number?(i)
        new(i, -d)
      end

      def double_augmented(i)
        augmented(i, 2)
      end

      def double_diminished(i)
        diminished(i, 2)
      end

      def tritone(n=1)
        if n.even?
          octave(n / 2)
        else
          s = n < 0 ? -1 : 1
          i = s * ((n.abs / 2) * 7 + 3)
          zero_based(i, 1)
        end
      end

      def with_semitones(interval, semitones)
        interval = new(interval) if interval.is_a? Fixnum
        interval = new(interval.number, 0) if interval.offset != 0
        offset = semitones - interval.semitones
        offset = -offset if interval.down?
        new(interval.number, offset)
      end

      def semitone_basis(number)
        case number
          when 1 then 0
          when 2 then 2
          when 3 then 4
          when 4 then 5
          when 5 then 7
          when 6 then 9
          when 7 then 11
          else
            raise ArgumentError, "Cannot get the semitone basis for interval number: #{number}"
        end
      end

      def parse(str, generic_as_major=false)
        str = str.to_s

        regex = /\A\s*(?:
          (([+\-]?)([pPuUmMAdsb#]+)?(\d+))|
          (([bs#]+)?([ivIV]+))
        )\s*\Z/x
        m = regex.match str
        raise ArgumentError, "Cannot parse #{str} as an Interval" unless m

        if m[1]
          # interval like P5
          quality_s = m[3]
          number = m[4].to_i
          number = -number if m[2] == '-'

          if quality_s
            offset = case quality_s[0]
              when 'p', 'P', 'u', 'U' then 0
              when 'm' then -1
              when 'M' then 0
              when 'A', 's', '#' then quality_s.length
              when 'd' then -quality_s.length - (major_minor_number?(number) ? 1 : 0)
              when 'b' then -quality_s.length
            end
          end

        else
          # roman numeral like bVII
          accidental = m[6]
          roman_numeral = m[7]
          offset = 0

          case roman_numeral
          when 'I', 'i'
            number = 1
          when 'ii', 'II'
            number = 2
          when 'iii'
            number = 3
          when 'III'
            number = 3
          when 'iv', 'IV'
            number = 4
          when 'v', 'V'
            number = 5
          when 'vi'
            number = 6
          when 'VI'
            number = 6
          when 'vii'
            number = 7
          when 'VII'
            number = 7
          when 'N'
            number = 2
            offset = -1
          else
            raise ArgumentError, "Cannot parse #{str} as an Interval"
          end

          if accidental
            offset += case accidental[0]
              when 's', '#' then accidental.length
              when 'b' then -accidental.length
            end
          end
        end

        offset = offset.to_i if generic_as_major

        new(number, offset)
      end
    end

  end
end
