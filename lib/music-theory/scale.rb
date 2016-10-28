module MusicTheory
  class Scale
    include Intervals

    attr_reader :intervals, :root

    def initialize(intervals, root=nil)
      @intervals = intervals.sort_by {|i| [i.number, i.offset]}
      @root = root
    end

    def with_root(root)
      Scale.new(intervals, root)
    end

    def without_root
      Scale.new(intervals)
    end

    def with_intervals(intervals)
      Scale.new(intervals, root)
    end

    def interval(i)
      if i.respond_to? :each
        i.map{|j| interval(j)}
      else
        raise ArgumentError, "interval must be non-zero" if i == 0
        i += i < 0 ? 1 : -1
        zero_based_interval(i)
      end
    end

    def note(i)
      raise ArgumentError, "Cannot get note for scale without a root" unless root

      if i == :all
        intervals.map{|i| (i + root)}
      elsif i.respond_to? :each
        i.map{|j| interval(j) + root}
      else
        interval(i) + root
      end
    end

    def notes(i=:all)
      note(i)
    end

    def zero_based_interval(i)
      d = i % length
      o = i / length
      result = intervals[d]
      result = result + Interval.octave(o) if o != 0
      result
    end

    def length
      intervals.length
    end

    def semitones
      intervals.map(&:semitones)
    end

    def [](i)
      if root
        root + zero_based_interval(i)
      else
        zero_based_interval(i)
      end
    end

    def to_s
      if root
        [root, name, "[#{notes_s}]"].compact.join(' ')
      else
        [name, "[#{intervals_s}]"].compact.join(' ')
      end
    end

    def inspect
      to_s
    end

    def notes_s
      raise ArgumentError, "Cannot get notes_s unless it has a root" unless root
      notes.map(&:to_s).join(' ')
    end

    def intervals_s
      intervals.map(&:scale_shorthand).join(' ')
    end

    def name
      Scale.common_name(self)
    end

    def rotate(n=1)
      basis = zero_based_interval(n)
      new_intervals = intervals.rotate(n).map{|i| (i - basis).modulo_octave}
      Scale.new(new_intervals, root)
    end

    def transpose(interval)
      raise ArgumentError, "Cannot transpose scale unless unless it has a root" unless root
      Scale.new(intervals, root + interval)
    end

    def +(interval)
      transpose(interval)
    end

    def -(interval)
      self + -interval
    end

    def ==(scale)
      return false unless scale.is_a? Scale
      return false unless scale.semitones == self.semitones
      if self.root && scale.root
        return false unless self.root == scale.root
      end
      true
    end

    def eql?(other)
      self == other && self.root == other.root
    end

    def hash
      [intervals, root].hash
    end

  end
end
