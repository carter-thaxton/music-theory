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

      if i.respond_to? :each
        i.map{|j| interval(j) + root}
      else
        interval(i) + root
      end
    end

    alias notes note

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
      intervals.map{|i| (root + i).to_s}.join(' ')
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
      self == other
    end

    def hash
      [intervals, root].hash
    end

    class << self
      COMMON_SCALES = [
        :major, :minor, :harmonic_minor, :melodic_minor,
        :dorian, :phrygian, :lydian, :mixolydian, :locrian,
        :dorian_b2, :lydian_augmented, :lydian_dominant, :mixolydian_b6, :locrian_2, :alt,
        :locrian_6, :ionian_augmented, :romanian, :phrygian_dominant, :lydian_2, :ultralocrian,
        :major_pentatonic, :minor_pentatonic, :whole_half_diminished, :half_whole_diminished, :whole_tone,
        :double_harmonic_minor
      ]

      def parse(str, root=nil)
        intervals = str.split.map {|i| Interval.parse(i, true) }
        new(intervals, root)
      end

      def common_name(scale)
        COMMON_SCALES.each do |name|
          common_scale = self.send(name)
          return name if common_scale == scale
        end
        nil
      end

      #
      # Common scales
      #
      def major(root=nil)
        Scale.parse("1 2 3 4 5 6 7", root)
      end

      def natural_minor(root=nil)
        Scale.parse("1 2 b3 4 5 b6 b7", root)
      end

      alias minor natural_minor
      alias aeolian natural_minor

      def harmonic_minor(root=nil)
        Scale.parse("1 2 b3 4 5 b6 7", root)
      end

      def melodic_minor(root=nil)
        Scale.parse("1 2 b3 4 5 6 7", root)
      end


      #
      # Modes of major
      #
      def dorian(root=nil)
        Scale.major(root).rotate(1)
      end

      def phrygian(root=nil)
        Scale.major(root).rotate(2)
      end

      def lydian(root=nil)
        Scale.major(root).rotate(3)
      end

      def mixolydian(root=nil)
        Scale.major(root).rotate(4)
      end

      def locrian(root=nil)
        Scale.major(root).rotate(6)
      end


      #
      # Modes of melodic minor
      #
      def dorian_b2(root=nil)
        Scale.melodic_minor(root).rotate(1)
      end

      def lydian_augmented(root=nil)
        Scale.melodic_minor(root).rotate(2)
      end

      def lydian_dominant(root=nil)
        Scale.melodic_minor(root).rotate(3)
      end

      def mixolydian_b6(root=nil)
        Scale.melodic_minor(root).rotate(4)
      end

      def locrian_2(root=nil)
        Scale.melodic_minor(root).rotate(5)
      end

      def alt(root=nil)
        # Same as melodic_minor.rotate(6), but uses enharmonic spellings #2 and 3, instead of b3 and b4
        Scale.parse("1 b2 #2 3 #4 b6 b7", root)
      end

      alias altered alt


      #
      # Modes of harmonic minor
      #
      def locrian_6(root=nil)
        Scale.harmonic_minor(root).rotate(1)
      end

      def ionian_augmented(root=nil)
        Scale.harmonic_minor(root).rotate(2)
      end

      def romanian(root=nil)
        Scale.harmonic_minor(root).rotate(3)
      end

      alias misheberakh romanian

      def phrygian_dominant(root=nil)
        Scale.harmonic_minor(root).rotate(4)
      end

      def lydian_2(root=nil)
        Scale.harmonic_minor(root).rotate(5)
      end

      def ultralocrian(root=nil)
        Scale.harmonic_minor(root).rotate(6)
      end


      #
      # Other scales
      #
      def major_pentatonic(root=nil)
        Scale.parse("1 2 3 5 6", root)
      end

      def minor_pentatonic(root=nil)
        Scale.parse("1 b3 4 5 b7", root)
      end

      def whole_half_diminished(root=nil)
        Scale.parse("1 2 b3 4 b5 b6 bb7 7", root)
      end

      def half_whole_diminished(root=nil)
        Scale.parse("1 b2 #2 3 #4 5 6 b7", root)
      end

      alias diminished whole_half_diminished

      def whole_tone(root=nil)
        Scale.parse("1 2 3 #4 #5 #6", root)
      end

      def double_harmonic_minor(root=nil)
        Scale.parse('1 b2 3 4 5 b6 bb7', root)
      end

    end

  end
end
