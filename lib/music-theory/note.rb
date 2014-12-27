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

    def +(n)
      n = n.to_interval
      idx = (diatonic_index + n.diatonic_offset) % 7
      oct = (diatonic_index + n.diatonic_offset) / 7
      Note.new(idx, accidentals, octave + oct)
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
