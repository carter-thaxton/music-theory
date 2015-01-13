module MusicTheory
  class Note
    attr_reader :diatonic_index, :accidentals, :octave

    def initialize(diatonic_index, accidentals=0, octave=nil)
      @diatonic_index = diatonic_index
      @accidentals = accidentals
      @octave = octave
    end

    def diatonic_s
      ('A'.ord + (diatonic_index + 2) % 7).chr
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
      result += "#{octave}" if octave
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
      basis = Interval.semitone_basis(diatonic_index + 1)
      basis + accidentals
    end

    def ==(note)
      return false unless note.is_a? Note
      return false unless note.diatonic_index == self.diatonic_index && note.accidentals == self.accidentals
      if note.octave && self.octave
        return false unless note.octave == self.octave
      end
      true
    end

    def +(interval)
      interval = Scale.major[interval] if interval.is_a? Fixnum

      idx = (diatonic_index + interval.diatonic_offset) % 7
      oct = (diatonic_index + interval.diatonic_offset) / 7
      result = Note.new(idx, accidentals, octave ? octave + oct : nil)

      if interval.specific?
        accidental_offset = chromatic_index - (result.chromatic_index + oct * 12) + interval.semitones
        result = result.sharp(accidental_offset)
      end

      result
    end

    def -(n)
      if n.is_a? Note
        n.measure_to self
      else
        self + -n
      end
    end

    def measure_to(note)
      if note.octave && self.octave
        oct = note.octave - self.octave
      else
        oct = note.diatonic_index < self.diatonic_index ? 1 : 0
      end
      c_idx = oct * 12 + note.chromatic_index - self.chromatic_index
      d_idx = oct * 7 + note.diatonic_index - self.diatonic_index
      Interval.with_semitones(Interval.zero_based(d_idx), c_idx)
    end

    def major
      Scale.major(self)
    end

    class << self
      def C (octave=nil); Note.new(0,  0, octave) end
      def Cb(octave=nil); Note.new(0, -1, octave) end
      def Cs(octave=nil); Note.new(0, +1, octave) end

      def D (octave=nil); Note.new(1,  0, octave) end
      def Db(octave=nil); Note.new(1, -1, octave) end
      def Ds(octave=nil); Note.new(1, +1, octave) end

      def E (octave=nil); Note.new(2,  0, octave) end
      def Eb(octave=nil); Note.new(2, -1, octave) end
      def Es(octave=nil); Note.new(2, +1, octave) end

      def F (octave=nil); Note.new(3,  0, octave) end
      def Fb(octave=nil); Note.new(3, -1, octave) end
      def Fs(octave=nil); Note.new(3, +1, octave) end

      def G (octave=nil); Note.new(4,  0, octave) end
      def Gb(octave=nil); Note.new(4, -1, octave) end
      def Gs(octave=nil); Note.new(4, +1, octave) end

      def A (octave=nil); Note.new(5,  0, octave) end
      def Ab(octave=nil); Note.new(5, -1, octave) end
      def As(octave=nil); Note.new(5, +1, octave) end

      def B (octave=nil); Note.new(6,  0, octave) end
      def Bb(octave=nil); Note.new(6, -1, octave) end
      def Bs(octave=nil); Note.new(6, +1, octave) end

      def parse(str)
        regex = /\A\s*([a-gA-G])\s*([s#]*)([b]*)\s*(\d+)?\s*\Z/
        m = regex.match str
        raise ArgumentError, "Cannot parse #{str} as a Note" unless m

        diatonic_index = ((m[1].upcase.ord - 'A'.ord) - 2) % 7
        sharps = m[2] ? m[2].length : 0
        flats = m[3] ? m[3].length : 0
        octave = m[4].to_i if m[4]

        new(diatonic_index, sharps - flats, octave)
      end
    end

  end
end
