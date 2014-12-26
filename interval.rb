
class Interval
  class InvalidIntervalError < ArgumentError; end

  attr_reader :offset, :type

  TYPES = [:perfect, :major, :minor, :augmented, :diminished]

  def initialize(offset, type=nil, down=false)
    @offset = offset.to_i

    # Use explicit down boolean to handle direction of diminished/augmented unisons
    raise InvalidIntervalError, "explicit down interval conflicts with non-zero offset" if down && @offset > 0
    @down = down || @offset < 0

    if type
      raise InvalidIntervalError, "invalid type: #{type}" unless TYPES.include?(type)
      @type = type

      case type
      when :major, :minor
        valid_offsets = [1, 2, 5, 6]
      when :perfect
        valid_offsets = [0, 3, 4]
      end

      raise InvalidIntervalError, "invalid interval: #{to_s}" if valid_offsets and !valid_offsets.include?(diatonic_offset)
    end
  end

  def ==(interval)
    return false unless interval.offset == self.offset
    if interval.specific? && self.specific?
      return false unless interval.type == self.type
    end
    true
  end

  def semitones
    raise InvalidIntervalError, "Cannot determine number of semitones for a generic interval" if generic?

    result = case type
      when :perfect
        case diatonic_offset
          when 0 then 0
          when 3 then 5
          when 4 then 7
        end
      when :major
        case diatonic_offset
          when 1 then 2
          when 2 then 4
          when 5 then 9
          when 6 then 11
        end
      when :minor
        case diatonic_offset
          when 1 then 1
          when 2 then 3
          when 5 then 8
          when 6 then 10
        end
      when :augmented
        case diatonic_offset
          when 0 then 1
          when 1 then 3
          when 2 then 5
          when 3 then 6
          when 4 then 8
          when 5 then 10
          when 6 then 12
        end
      when :diminished
        case diatonic_offset
          when 0 then -1
          when 1 then 1
          when 2 then 2
          when 3 then 4
          when 4 then 6
          when 5 then 8
          when 6 then 9
        end
    end

    raise "Unhandled case" if result.nil?

    result = -result if down?
    result += octave_offset * 12
    result
  end

  def generic?
    type.nil?
  end

  def specific?
    !generic?
  end

  def up?
    offset > 0
  end

  def down?
    @down
  end

  def unison?
    offset == 0
  end

  def unison_or_octave?
    diatonic_offset == 0
  end

  alias octave_or_unison? unison_or_octave?

  def octave?
    unison_or_octave? and not unison?
  end

  def perfect?
    type == :perfect
  end

  def major?
    type == :major
  end

  def minor?
    type == :minor
  end

  def augmented?
    type == :augmented
  end

  def diminished?
    type == :diminished
  end

  def to_s
    dir_s = "down " if offset < 0
    type_s = "#{type} " if type && diatonic_offset != 0
    "#{dir_s}#{type_s}#{ord_s}"
  end

  def diatonic_offset
    offset.abs % 7
  end

  def octave_offset
    s = offset < 0 ? -1 : 1
    (offset.abs / 7) * s
  end

  def inspect
    to_s
  end

  def to_interval
    self
  end

  private

  def ord_s
    i = offset.abs
    case i
    when 0 then "unison"
    when 1 then "2nd"
    when 2 then "3rd"
    else
      if i % 7 == 0
        n = i / 7
        if n == 1 then "octave" else "#{n} octaves" end
      else
        "#{i+1}th"
      end
    end
  end

  class << self
    def zero_based(offset, type=nil)
      Interval.new(offset, type)
    end

    def one_based(offset, type=nil)
      o = offset.to_i
      raise "offset must be a non-zero integer" if o == 0
      s = o < 0 ? -1 : 1

      # Explicitly handle diminished/augmented unisons with an extra boolean parameter
      Interval.new(o - s, type, o < 0)
    end

    def unison; zero_based(0, :perfect); end
    def octave(n=1); zero_based(7*n, :perfect); end
    def perfect(i); one_based(i, :perfect); end
    def major(i); one_based(i, :major); end
    def minor(i); one_based(i, :minor); end
    def augmented(i); one_based(i, :augmented); end
    def diminished(i); one_based(i, :diminished); end
  end

end

class Fixnum
  def to_interval(type=nil); Interval.zero_based(self, type); end
end
