
class Interval
  attr_reader :offset, :type

  TYPES = [:perfect, :major, :minor, :augmented, :diminished]

  def initialize(offset, type=nil)
    @offset = offset.to_i

    if type
      raise "invalid type: #{type}" unless TYPES.include?(type)
      @type = type

      case type
      when :major, :minor
        valid_offsets = [1, 2, 5, 6]
      when :perfect
        valid_offsets = [0, 3, 4]
      end

      raise "invalid interval: #{to_s}" if valid_offsets and !valid_offsets.include?(diatonic_offset)
    end
  end

  def to_s
    dir_s = "down " if offset < 0
    type_s = "#{type} " if type and diatonic_offset != 0
    "#{dir_s}#{type_s}#{ord_s}"
  end

  def diatonic_offset
    offset.abs % 7
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
      Interval.new(o - s, type)
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
