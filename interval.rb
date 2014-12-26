
class Interval
  class InvalidIntervalError < ArgumentError; end

  attr_reader :number, :quality

  QUALITIES = [:perfect, :major, :minor, :augmented, :diminished, :double_augmented, :double_diminished]

  def initialize(number, quality=nil)
    @number = number.to_i
    raise InvalidIntervalError, "number must be a non-zero integer" if @number == 0

    if quality
      raise InvalidIntervalError, "invalid quality: #{quality}" unless QUALITIES.include?(quality)
      @quality = quality

      case quality
      when :major, :minor
        valid_numbers = [2, 3, 6, 7]
      when :perfect
        valid_numbers = [1, 4, 5]
      end

      raise InvalidIntervalError, "invalid interval: #{to_s}" if valid_numbers and !valid_numbers.include?(scale_number)
    end
  end

  def ==(interval)
    return false unless interval.number == self.number
    if interval.specific? && self.specific?
      return false unless interval.quality == self.quality
    end
    true
  end

  def semitones
    raise InvalidIntervalError, "Cannot determine number of semitones for a generic interval" if generic?

    result = case quality
      when :perfect
        case scale_number
          when 1 then 0
          when 4 then 5
          when 5 then 7
        end
      when :major
        case scale_number
          when 2 then 2
          when 3 then 4
          when 6 then 9
          when 7 then 11
        end
      when :minor
        case scale_number
          when 2 then 1
          when 3 then 3
          when 6 then 8
          when 7 then 10
        end
      when :augmented
        case scale_number
          when 1 then 1
          when 2 then 3
          when 3 then 5
          when 4 then 6
          when 5 then 8
          when 6 then 10
          when 7 then 12
        end
      when :diminished
        case scale_number
          when 1 then -1
          when 2 then 0
          when 3 then 2
          when 4 then 4
          when 5 then 6
          when 6 then 7
          when 7 then 9
        end
      when :double_augmented
        case scale_number
          when 1 then 2
          when 2 then 4
          when 3 then 6
          when 4 then 7
          when 5 then 9
          when 6 then 11
          when 7 then 13
        end
      when :double_diminished
        case scale_number
          when 1 then -2
          when 2 then -1
          when 3 then 1
          when 4 then 3
          when 5 then 5
          when 6 then 6
          when 7 then 8
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
    scale_number == 1
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

  def double_augmented?
    quality == :double_augmented
  end

  def double_diminished?
    quality == :double_diminished
  end

  def to_s
    dir_s = "down " if down?
    quality_s = "#{quality.to_s.gsub('_', '-')} " if specific? and not (perfect? and unison_or_octave?)
    "#{dir_s}#{quality_s}#{ord_s}"
  end

  def scale_number
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
    def one_based(number, quality=nil)
      Interval.new(number, quality)
    end

    def zero_based(offset, quality=nil)
      offset += (offset < 0 ? -1 : 1)
      Interval.new(offset, quality)
    end

    def unison; zero_based(0, :perfect); end
    def octave(n=1); zero_based(7*n, :perfect); end
    def perfect(i); one_based(i, :perfect); end
    def major(i); one_based(i, :major); end
    def minor(i); one_based(i, :minor); end
    def augmented(i); one_based(i, :augmented); end
    def diminished(i); one_based(i, :diminished); end
    def double_augmented(i); one_based(i, :double_augmented); end
    def double_diminished(i); one_based(i, :double_diminished); end

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

class Fixnum
  def to_interval(quality=nil); Interval.zero_based(self, quality); end
end
