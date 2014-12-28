module MusicTheory
  class Note
    attr_reader :diatonic_index, :accidentals, :octave

    def initialize(diatonic_index, accidentals=0, octave=4)
      @diatonic_index = diatonic_index
      @accidentals = accidentals
      @octave = octave
    end

    def diatonic_s
      ("A".ord + (diatonic_index + 2) % 7).chr
    end

    def accidental_s
      if accidentals < 0
        'b' * -accidentals
      else
        '#' * accidentals
      end
    end

    def to_s(opts = {})
      result = "#{diatonic_s}#{accidental_s}"
      result += "#{octave}" if opts[:octave]
      result
    end

    def inspect(opts = {})
      to_s(opts)
    end

    def sharp(n=1)
      n = n.to_i
      Note.new(diatonic_index, accidentals + n, octave)
    end

    def flat(n=1)
      sharp(-n)
    end

    def chromatic_index
      basis = case diatonic_index
        when 0 then 0
        when 1 then 2
        when 2 then 4
        when 3 then 5
        when 4 then 7
        when 5 then 9
        when 6 then 11
      end
      basis + accidentals
    end

    def chromatic_offset
      chromatic_index + octave * 12
    end

    def ==(interval)
      return interval.diatonic_index == self.diatonic_index &&
        interval.accidentals == self.accidentals &&
        interval.octave == self.octave
    end

    def +(interval)
      interval = Interval.zero_based(interval) if interval.is_a? Fixnum

      idx = (diatonic_index + interval.offset) % 7
      oct = (diatonic_index + interval.offset) / 7
      result = Note.new(idx, accidentals, octave + oct)

      if interval.specific?
        acc_offset = (chromatic_offset - result.chromatic_offset) + interval.semitones
        result = result.sharp(acc_offset)
      end

      result
    end

    def -(n)
      self + -n
    end

    class << self
      def C (octave=4); Note.new(0,  0, octave) end
      def Cb(octave=4); Note.new(0, -1, octave) end
      def Cs(octave=4); Note.new(0, +1, octave) end

      def D (octave=4); Note.new(1,  0, octave) end
      def Db(octave=4); Note.new(1, -1, octave) end
      def Ds(octave=4); Note.new(1, +1, octave) end

      def E (octave=4); Note.new(2,  0, octave) end
      def Eb(octave=4); Note.new(2, -1, octave) end
      def Es(octave=4); Note.new(2, +1, octave) end

      def F (octave=4); Note.new(3,  0, octave) end
      def Fb(octave=4); Note.new(3, -1, octave) end
      def Fs(octave=4); Note.new(3, +1, octave) end

      def G (octave=4); Note.new(4,  0, octave) end
      def Gb(octave=4); Note.new(4, -1, octave) end
      def Gs(octave=4); Note.new(4, +1, octave) end

      def A (octave=4); Note.new(5,  0, octave) end
      def Ab(octave=4); Note.new(5, -1, octave) end
      def As(octave=4); Note.new(5, +1, octave) end

      def B (octave=4); Note.new(6,  0, octave) end
      def Bb(octave=4); Note.new(6, -1, octave) end
      def Bs(octave=4); Note.new(6, +1, octave) end
    end

  end
end
