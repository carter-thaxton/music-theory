module MusicTheory
  class Interval
    class InvalidIntervalError < ArgumentError; end

    attr_reader :number, :quality, :quality_count

    QUALITIES = [:perfect, :major, :minor, :augmented, :diminished]

    def initialize(number, quality=nil, quality_count=nil)
      @number = number.to_i
      raise InvalidIntervalError, "number must be a non-zero integer" if @number == 0

      if quality
        raise InvalidIntervalError, "invalid quality: #{quality}" unless QUALITIES.include?(quality)
        @quality = quality

        case quality
        when :major, :minor
          raise InvalidIntervalError, "invalid interval: #{to_s}" unless major_minor_number?
        when :perfect
          raise InvalidIntervalError, "invalid interval: #{to_s}" unless perfect_number?
        end

        if quality == :diminished || quality == :augmented
          @quality_count = quality_count || 1
          raise InvalidIntervalError, "invalid quality_count: #{quality_count} for #{quality}" unless @quality_count > 0
        else
          @quality_count = 0
        end
      end
    end

    def ==(interval)
      return false unless interval.is_a? Interval
      return false unless interval.number == self.number
      if interval.specific? && self.specific?
        return false unless interval.quality == self.quality && interval.quality_count == self.quality_count
      end
      true
    end

    def semitones
      raise InvalidIntervalError, "Cannot determine number of semitones for a generic interval" if generic?

      result = case quality
        when :perfect, :major, :augmented
          case abs_simple_number
            when 1 then 0 + quality_count
            when 2 then 2 + quality_count
            when 3 then 4 + quality_count
            when 4 then 5 + quality_count
            when 5 then 7 + quality_count
            when 6 then 9 + quality_count
            when 7 then 11 + quality_count
          end
        when :minor, :diminished
          case abs_simple_number
            when 1 then 0 - quality_count
            when 2 then 1 - quality_count
            when 3 then 3 - quality_count
            when 4 then 5 - quality_count
            when 5 then 7 - quality_count
            when 6 then 8 - quality_count
            when 7 then 10 - quality_count
          end
      end

      raise "Unhandled case" if result.nil?

      result = -result if down?
      result += octave_offset * 12
      result
    end

    def generic?
      quality.nil?
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
      abs_simple_number == 1
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

    def perfect_number?
      [1,4,5].include? abs_simple_number
    end

    def major_minor_number?
      [2,3,6,7].include? abs_simple_number
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

      s = number < 0 ? '-' : ''
      "#{s}#{quality_s}#{number.abs}"
    end

    def simple
      Interval.new(simple_number, quality, quality_count)
    end

    def simple_number
      down? ? -abs_simple_number : abs_simple_number
    end

    def abs_simple_number
      (number.abs - 1) % 7 + 1
    end

    def modulo_octave
      result = simple
      if result.down?
        result = result.inverse unless result.unison?
        result = result.abs
      end
      result
    end

    def offset
      down? ? number + 1 : number - 1
    end

    def octave_offset
      s = down? ? -1 : 1
      ((number.abs - 1) / 7) * s
    end

    def inspect
      to_s
    end

    def to_interval
      self
    end

    def augment(n=1)
      if n == 0
        self
      elsif n < 0
        diminish(-n)
      elsif n > 1
        result = self
        n.times do
          result = result.augment
        end
        result
      else
        case quality
        when :perfect, :major
          Interval.new(number, :augmented, 1)
        when :minor
          Interval.new(number, :major)
        when :diminished
          q = quality_count - 1
          if q == 0
            if perfect_number?
              Interval.new(number, :perfect)
            else
              Interval.new(number, :minor)
            end
          else
            Interval.new(number, :diminished, q)
          end
        when :augmented
          Interval.new(number, :augmented, quality_count + 1)
        end
      end
    end

    def diminish(n=1)
      if n == 0
        self
      elsif n < 0
        augment(-n)
      elsif n > 1
        result = self
        n.times do
          result = result.diminish
        end
        result
      else
        case quality
        when :perfect, :minor
          Interval.new(number, :diminished, 1)
        when :major
          Interval.new(number, :minor)
        when :diminished
          Interval.new(number, :diminished, quality_count + 1)
        when :augmented
          q = quality_count - 1
          if q == 0
            if perfect_number?
              Interval.new(number, :perfect)
            else
              Interval.new(number, :major)
            end
          else
            Interval.new(number, :augmented, q)
          end
        end
      end
    end

    alias augmented augment
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
      Interval.new(-number, quality, quality_count)
    end

    def -(interval)
      self + -interval
    end

    def +(interval)
      return interval + self if interval.is_a? Note

      interval = Scale.major[interval] if interval.is_a? Fixnum

      n = interval.offset + self.offset
      o = n < 0 || n == 0 && self.down? ? -1 : 1
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
      def zero_based(offset, quality=nil, quality_count=nil)
        number = offset + (offset < 0 ? -1 : 1)
        new(number, quality, quality_count)
      end

      def generic(i); new(i); end
      def unison; new(1, :perfect); end
      def octave(n=1); zero_based(7*n, :perfect); end
      def perfect(i); new(i, :perfect); end
      def major(i); new(i, :major); end
      def minor(i); new(i, :minor); end
      def augmented(i, a=1); new(i, :augmented, a); end
      def diminished(i, d=1); new(i, :diminished, d); end
      def double_augmented(i); new(i, :augmented, 2); end
      def double_diminished(i); new(i, :diminished, 2); end

      def tritone(n=1)
        if n.even?
          octave(n / 2)
        else
          s = n < 0 ? -1 : 1
          i = s * ((n.abs / 2) * 7 + 3)
          zero_based(i, :augmented)
        end
      end

      def with_semitones(interval, semitones)
        interval = new(interval) if interval.is_a? Fixnum

        basis = case interval.abs_simple_number
          when 1 then 0
          when 2 then 2
          when 3 then 4
          when 4 then 5
          when 5 then 7
          when 6 then 9
          when 7 then 11
        end

        s = semitones - interval.octave_offset * 12
        s = -s if interval.down?
        offset = s - basis

        if interval.perfect_number?
          if offset < 0
            quality = :diminished
            quality_count = -offset
          elsif offset == 0
            quality = :perfect
          else
            quality = :augmented
            quality_count = offset
          end
        else
          if offset < -1
            quality = :diminished
            quality_count = -offset - 1
          elsif offset == -1
            quality = :minor
          elsif offset == 0
            quality = :major
          else
            quality = :augmented
            quality_count = offset
          end
        end

        new(interval.number, quality, quality_count)
      end

      def parse(str, generic_as_major=false)
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

          perfect_number = [1,4,5].include?((number.abs - 1) % 7 + 1)

          if quality_s
            quality_count = quality_s.length
            quality = case quality_s[0]
              when 'p', 'P', 'u', 'U' then :perfect
              when 'm' then :minor
              when 'M' then :major
              when 'A', 's', '#' then :augmented
              when 'd' then :diminished
              when 'b'
                if perfect_number
                  :diminished
                elsif quality_count == 1
                  :minor
                else
                  quality_count -= 1
                  :diminished
                end
            end
          elsif generic_as_major
            quality = perfect_number ? :perfect : :major
            quality_count = 0
          end

        else
          # roman numeral like bVII
          accidental = m[6]
          roman_numeral = m[7]

          case roman_numeral
          when 'I', 'i'
            number = 1
            quality = :perfect
          when 'ii', 'II'
            number = 2
            quality = :major
          when 'iii'
            number = 3
            quality = :major
          when 'III'
            number = 3
            quality = :minor
          when 'iv', 'IV'
            number = 4
            quality = :perfect
          when 'v', 'V'
            number = 5
            quality = :perfect
          when 'vi'
            number = 6
            quality = :major
          when 'VI'
            number = 6
            quality = :minor
          when 'vii'
            number = 7
            quality = :major
          when 'VII'
            number = 7
            quality = :minor
          else
            raise ArgumentError, "Cannot parse #{str} as an Interval"
          end

          if accidental
            case accidental[0]
            when 's', '#'
              case quality
              when :major, :perfect
                quality = :augmented
                quality_count = accidental.length
              when :minor
                if accidental.length == 1
                  quality = :major
                else
                  quality = :augmented
                  quality_count = accidental.length - 1
                end
              end
            when 'b'
              case quality
              when :major
                if accidental.length == 1
                  quality = :minor
                else
                  quality = :diminished
                  quality_count = accidental.length - 1
                end
              when :minor, :perfect
                quality = :diminished
                quality_count = accidental.length
              end
            end
          end
        end

        new(number, quality, quality_count)
      end
    end

  end
end
