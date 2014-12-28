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
          case simple_number
            when 1 then 0 + quality_count
            when 2 then 2 + quality_count
            when 3 then 4 + quality_count
            when 4 then 5 + quality_count
            when 5 then 7 + quality_count
            when 6 then 9 + quality_count
            when 7 then 11 + quality_count
          end
        when :minor, :diminished
          case simple_number
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

    def perfect_number?(n=simple_number)
      [1,4,5].include? n
    end

    def major_minor_number?(n=simple_number)
      [2,3,6,7].include? n
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

    def simple_number
      (number.abs - 1) % 7 + 1
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
      pivot = down? ? -8 : 8
      n = pivot - number
      o = n < 0 || n == 0 && down? ? -1 : 1
      new_number = n + o

      if generic?
        Interval.new(new_number)
      else
        new_quality = if simple?
          case quality
            when :perfect then :perfect
            when :major then :minor
            when :minor then :major
            when :augmented then :diminished
            when :diminished then :augmented
          end
        else
          quality
        end
        Interval.new(new_number, new_quality, quality_count)
      end
    end

    def abs
      down? ? -self : self
    end

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
      interval = Interval.zero_based(interval) if interval.is_a? Fixnum

      i = interval.number + (interval.down? ? 1 : -1)
      j = self.number + (self.down? ? 1 : -1)
      n = i + j
      o = n < 0 || n == 0 && down? ? -1 : 1
      new_number = n + o

      if self.generic? or interval.generic?
        return Interval.new(new_number)
      else
        raise "Cannot handle specific intervals yet"
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
        else
          "#{i}th"
        end
      end
    end

    class << self
      def zero_based(offset, quality=nil, quality_count=nil)
        offset += (offset < 0 ? -1 : 1)
        new(offset, quality, quality_count)
      end

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
    end

  end

end
