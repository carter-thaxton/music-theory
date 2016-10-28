module MusicTheory
  class << Scale
    COMMON_SCALES = [
      :chromatic, :flat_chromatic,
      :major, :natural_minor, :harmonic_minor, :melodic_minor,
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
    def chromatic(root=nil)
      Scale.parse("1 #1 2 #2 3 4 #4 5 #5 6 #6 7")
    end

    def flat_chromatic(root=nil)
      Scale.parse("1 b2 2 b3 3 4 b5 5 b6 6 b7 7")
    end

    alias sharp_chromatic chromatic
    alias ascending_chromatic sharp_chromatic
    alias descending_chromatic flat_chromatic

    def major(root=nil)
      Scale.parse("1 2 3 4 5 6 7", root)
    end

    alias ionian major

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
      # Same as melodic_minor.rotate(6), but uses enharmonic spellings #2, 3, #4, instead of b3, b4, b5
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
