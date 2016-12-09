require 'test/unit'
require 'music-theory'

class ChordTest < Test::Unit::TestCase
  include MusicTheory

  def test_major
    c = Chord.major
    assert_equal :major, c.quality
    assert_equal 3, c.length
    assert_equal [Interval.unison, Interval.major(3), Interval.perfect(5)], c.intervals
  end

  def test_equality
    assert_equal Chord.major, Chord.major
    assert_equal Chord.major(Note.C), Chord.major
    assert_equal Chord.major, Chord.major(Note.C)
    assert_equal Chord.major(Note.C), Chord.major(Note.C)
    assert_not_equal Chord.major(Note.C), Chord.major(Note.D)
    assert_not_equal Chord.major, Chord.minor
    assert_equal Chord.dominant, Chord.major.add('b7')
    assert_equal Chord.dominant.flat(9), Chord.major.add('b7').add('b9')
    assert Chord.major.eql?(Chord.major)
    assert Chord.major(Note.C).eql?(Chord.major(Note.C))
    assert !Chord.major(Note.C).eql?(Chord.major)
    assert !Chord.major.eql?(Chord.major(Note.C))
    assert_equal [Chord.major], [Chord.major, Chord.major].uniq
  end

  def test_no_duplicates
    assert_equal Chord.parse_intervals('1 3 5'), Chord.parse_intervals('1 1 3 5')
    assert_equal Chord.parse_intervals('1 3 5 9'), Chord.parse_intervals('1 2 3 5 9')
  end

  def test_quality
    assert_equal :major, Chord.major.quality
    assert_equal :minor, Chord.minor.quality
    assert_equal :augmented, Chord.augmented.quality
    assert_equal :diminished, Chord.diminished.quality
    assert_equal :suspended, Chord.suspended.quality
  end

  def test_helpers
    assert Chord.major.major?
    assert !Chord.major.minor?
    assert !Chord.major.diminished?
    assert !Chord.augmented.diminished?
    assert Chord.augmented.augmented?
    assert Chord.dominant.major?
    assert Chord.dominant.dominant?
  end

  def test_alterations
    assert_equal Chord.minor, Chord.major.flat(3)
    assert_equal Chord.major, Chord.minor.sharp(3)
    assert_equal Chord.diminished, Chord.minor.flat(5)
    assert_equal Chord.augmented, Chord.major.sharp(5)
  end

  def test_rootless
    assert Chord.major.no(1).rootless?
  end

  def test_from_notes
    assert_equal 'C', Chord.from_notes([Note.C, Note.E, Note.G]).to_s
    assert_equal 'C7', Chord.from_notes([Note.C, Note.E, Note.G, Note.Bb]).to_s
    assert_equal 'C7#11', Chord.from_notes([Note.C, Note.E, Note.Fs, Note.G, Note.Bb]).to_s
    assert_equal 'C', Chord.from_notes([Note.C(4), Note.E(5), Note.G(6)]).to_s
  end

  def test_with_root
    assert_equal 'D', Chord.major(Note.C).with_root(Note.D).to_s
  end

  def test_transpose
    c = Chord.parse('C∆')
    assert_equal 'C∆', c.transpose(Interval.unison).to_s
    assert_equal 'A∆', c.transpose(Interval.minor(-3)).to_s

    c = Chord.parse('II7')
    assert_equal 'II7', c.transpose(Interval.unison).to_s
    assert_equal 'VII7', c.transpose(Interval.minor(-3)).to_s

    c = Chord.parse('maj7')
    assert_equal 'I∆', c.transpose(Interval.unison).to_s
    assert_equal 'VI∆', c.transpose(Interval.minor(-3)).to_s
  end

  def test_reinterpret_root_with_intervals
    c = Chord.parse('C∆')
    assert_equal 'C∆', c.reinterpret_root(Interval.unison).to_s
    assert_equal 'Am9', c.reinterpret_root(Interval.minor(-3)).to_s

    c = Chord.parse('II∆')
    assert_equal 'II∆', c.reinterpret_root(Interval.unison).to_s
    assert_equal 'vii9', c.reinterpret_root(Interval.minor(-3)).to_s

    c = Chord.parse('∆')
    assert_equal 'I∆', c.reinterpret_root(Interval.unison).to_s
    assert_equal 'vi9', c.reinterpret_root(Interval.minor(-3)).to_s
  end

  def test_reinterpret_root_with_notes
    c = Chord.parse('C')
    assert_equal 'C', c.reinterpret_root(Note.C).to_s
    assert_equal 'Emb6', c.reinterpret_root(Note.E).to_s
    assert_equal 'Bb69#4', c.reinterpret_root(Note.Bb).to_s
    assert_equal 'F∆sus2', c.reinterpret_root(Note.F).to_s
    assert_equal 'F#m7b5b9', c.reinterpret_root(Note.Fs).to_s

    c = Chord.parse('C7')
    assert_equal 'C7', c.reinterpret_root(Note.C).to_s
    assert_equal 'Eºb6', c.reinterpret_root(Note.E).to_s
    assert_equal 'Bb69#4', c.reinterpret_root(Note.Bb).to_s
    assert_equal 'F∆9sus4', c.reinterpret_root(Note.F).to_s
    assert_equal 'F#7b4b5b9', c.reinterpret_root(Note.Fs).to_s

    c = Chord.parse('C7add13')
    assert_equal 'C13', c.reinterpret_root(Note.C).to_s
    assert_equal 'Eºb6add11', c.reinterpret_root(Note.E).to_s
    assert_equal 'Bb∆13#11', c.reinterpret_root(Note.Bb).to_s
    assert_equal 'F∆11', c.reinterpret_root(Note.F).to_s
    assert_equal 'F#m7b5b9b11', c.reinterpret_root(Note.Fs).to_s
  end

  def test_reinterpret_root_abstract
    c = Chord.parse('7add13')
    assert_equal 'I13', c.reinterpret_root(Interval.unison).to_s
    assert_equal 'iiiºb6add11', c.reinterpret_root(Interval.major(3)).to_s
    assert_equal 'bVII∆13#11', c.reinterpret_root(Interval.major(-2)).to_s
    assert_equal 'IV∆11', c.reinterpret_root(Interval.perfect(4)).to_s
    assert_equal '#ivøb9b11', c.reinterpret_root(Interval.tritone).to_s

    c = Chord.parse('I7add13')
    assert_equal 'I13', c.reinterpret_root(Interval.unison).to_s
    assert_equal 'iiiºb6add11', c.reinterpret_root(Interval.major(3)).to_s
    assert_equal 'bVII∆13#11', c.reinterpret_root(Interval.major(-2)).to_s
    assert_equal 'IV∆11', c.reinterpret_root(Interval.perfect(4)).to_s
    assert_equal '#ivøb9b11', c.reinterpret_root(Interval.tritone).to_s

    c = Chord.parse('II7add13')
    assert_equal 'II13', c.reinterpret_root(Interval.unison).to_s
    assert_equal '#ivºb6add11', c.reinterpret_root(Interval.major(3)).to_s
    assert_equal 'I∆13#11', c.reinterpret_root(Interval.major(-2)).to_s
    assert_equal 'V∆11', c.reinterpret_root(Interval.perfect(4)).to_s
    assert_equal '#vøb9b11', c.reinterpret_root(Interval.tritone).to_s

    c = Chord.parse('7add13')
    assert_equal 'C13', c.reinterpret_root(Note.C).to_s
    assert_equal 'E13', c.reinterpret_root(Note.E).to_s

    c = Chord.parse('I7add13')
    assert_equal 'C13', c.reinterpret_root(Note.C).to_s
    assert_equal 'E13', c.reinterpret_root(Note.E).to_s

    c = Chord.parse('bVII7add13')
    assert_equal 'Bb∆13#11', c.reinterpret_root(Note.C).to_s
    assert_equal 'D∆13#11', c.reinterpret_root(Note.E).to_s
  end

  def test_relative_to
    c = Chord.parse('C∆')
    assert_equal 'bVI∆', c.relative_to(Note.E).to_s
    assert_equal 'V∆', c.relative_to(Note.F).to_s
    assert_equal 'V∆', c.relative_to(Chord.major(Note.F)).to_s
    assert_equal 'V∆', c.relative_to(Scale.major(Note.F)).to_s
    assert_equal 'I∆', c.relative_to(Interval.unison).to_s
    assert_equal 'V∆', c.relative_to(Interval.perfect(4)).to_s
    assert_equal 'bVII∆', c.relative_to(Interval.major(2)).to_s

    c = Chord.parse('∆')
    assert_equal 'E∆', c.relative_to(Note.E).to_s
    assert_equal 'F∆', c.relative_to(Note.F).to_s
    assert_equal 'F∆', c.relative_to(Chord.major(Note.F)).to_s
    assert_equal 'F∆', c.relative_to(Scale.major(Note.F)).to_s
    assert_equal 'I∆', c.relative_to(Interval.unison).to_s
    assert_equal 'V∆', c.relative_to(Interval.perfect(4)).to_s
    assert_equal 'bVII∆', c.relative_to(Interval.major(2)).to_s

    c = Chord.parse('I∆')
    assert_equal 'E∆', c.relative_to(Note.E).to_s
    assert_equal 'F∆', c.relative_to(Note.F).to_s
    assert_equal 'F∆', c.relative_to(Chord.major(Note.F)).to_s
    assert_equal 'F∆', c.relative_to(Scale.major(Note.F)).to_s
    assert_equal 'I∆', c.relative_to(Interval.unison).to_s
    assert_equal 'V∆', c.relative_to(Interval.perfect(4)).to_s
    assert_equal 'bVII∆', c.relative_to(Interval.major(2)).to_s

    c = Chord.parse('IV∆')
    assert_equal 'A∆', c.relative_to(Note.E).to_s
    assert_equal 'Bb∆', c.relative_to(Note.F).to_s
    assert_equal 'Bb∆', c.relative_to(Chord.major(Note.F)).to_s
    assert_equal 'Bb∆', c.relative_to(Scale.major(Note.F)).to_s
    assert_equal 'IV∆', c.relative_to(Interval.unison).to_s
    assert_equal 'I∆', c.relative_to(Interval.perfect(4)).to_s
    assert_equal 'bIII∆', c.relative_to(Interval.major(2)).to_s
  end

  def test_with_bass
    c = Chord.major(Note.C)
    assert_equal Note.C, c.root
    assert_equal Interval.unison, c.bass
    assert_equal Note.C, c.bass_note
    assert_equal 0, c.inversion

    c = Chord.major(Note.C).over(Note.E)
    assert_equal Note.C, c.root
    assert_equal Interval.major(3), c.bass
    assert_equal Note.E, c.bass_note
    assert_equal 1, c.inversion

    c = Chord.parse('C/E')
    assert_equal Note.C, c.root
    assert_equal Interval.major(3), c.bass
    assert_equal Note.E, c.bass_note
    assert_equal 'C/E', c.to_s
    assert_equal 1, c.inversion

    c = Chord.parse('IV/6')
    assert_equal Interval.perfect(4), c.root
    assert_equal Interval.major(3), c.bass
    assert_equal 'IV/6', c.to_s
    assert_equal 1, c.inversion

    c = Chord.parse('IV/64')
    assert_equal Interval.perfect(4), c.root
    assert_equal Interval.perfect(5), c.bass
    assert_equal 'IV/64', c.to_s
    assert_equal 2, c.inversion

    c = Chord.parse('IV7/65')
    assert_equal Interval.perfect(4), c.root
    assert_equal Interval.major(3), c.bass
    assert_equal 'IV7/65', c.to_s
    assert_equal 1, c.inversion

    c = Chord.parse('IV7/43')
    assert_equal Interval.perfect(4), c.root
    assert_equal Interval.perfect(5), c.bass
    assert_equal 'IV7/43', c.to_s
    assert_equal 2, c.inversion

    c = Chord.parse('IV7/42')
    assert_equal Interval.perfect(4), c.root
    assert_equal Interval.minor(7), c.bass
    assert_equal 'IV7/42', c.to_s
    assert_equal 3, c.inversion

    c = Chord.parse('C/F')
    assert_equal Note.C, c.root
    assert_equal Interval.perfect(4), c.bass
    assert_equal Note.F, c.bass_note
    assert_equal 'C/F', c.to_s
    assert_nil c.inversion

    c = c.with_root(nil)
    assert_nil c.root
    assert_equal Interval.perfect(4), c.bass
    assert_equal 'maj/P4', c.to_s
    assert_nil c.inversion
  end

  def test_parse_major
    c = Chord.parse('C')
    assert_equal Note.C, c.root
    assert_equal Chord.major(Note.C), c
  end

  def test_parse_no_root
    c = Chord.parse('')
    assert_nil c.root
    assert_equal Chord.major, c
  end

  def test_parse_minor
    cm = Chord.parse('Cm')
    assert_equal Note.C, cm.root
    assert_equal Chord.minor(Note.C), cm
  end

  def test_parse_dominant
    c = Chord.parse('C7')
    assert_equal Note.C, c.root
    assert_equal Chord.dominant(Note.C), c
  end

  def test_parse_major_seventh
    c = Chord.parse('C∆')
    assert_equal Note.C, c.root
    assert_equal Chord.major(Note.C).add(7), c
  end

  def test_parse_interval_root
    c = Chord.parse('V7')
    assert_equal Interval.perfect(5), c.root
    assert c.dominant?

    c = Chord.parse('iv')
    assert_equal Interval.perfect(4), c.root
    assert c.minor?

    c = Chord.parse('bII7')
    assert_equal Interval.minor(2), c.root
    assert c.dominant?
  end

  def test_to_s
    assert_equal 'maj', Chord.parse('').to_s
    assert_equal 'C', Chord.parse('C').to_s
    assert_equal 'Cm', Chord.parse('Cm').to_s
    assert_equal 'Cm7b5', Chord.parse('Cm7b5').to_s
    assert_equal 'Cm7b5', Chord.parse('Cø').to_s
    assert_equal 'viiø', Chord.parse('viiø').to_s
    assert_equal 'bVI', Chord.parse('bVI').to_s
  end

  def test_sixth_chords
    c = Chord.parse('C6')
    assert_equal '1 3 5 6', c.intervals_s
    assert_equal 'C6', c.to_s

    c = Chord.parse('C69')
    assert_equal '1 3 5 6 9', c.intervals_s
    assert_equal 'C69', c.to_s

    c = Chord.parse('C∆13')
    assert_equal '1 3 5 7 9 11 13', c.intervals_s
    assert_equal 'C∆13', c.to_s
  end

  def test_alt
    c = Chord.parse('alt')
    assert_equal '1 3 b5 b7 b9 #9 b13', c.intervals_s
    assert_equal '7alt', c.to_s
  end

  def test_suspended
    assert_equal '1 2 5', Chord.parse('sus2').intervals_s
    assert_equal '1 4 5', Chord.parse('sus4').intervals_s
    assert_equal '1 4 5', Chord.parse('sus').intervals_s
  end

  def test_minor_sharp_five
    assert_equal :minor, Chord.parse('m7#5').quality
  end

  def test_augmented
    assert_equal '1 3 #5', Chord.parse('+').intervals_s
    assert_equal '+', Chord.parse('+').to_s
    assert_equal '+6', Chord.parse('+6').to_s
    assert_equal '7#5', Chord.parse('+7').to_s
    assert_equal '7#5', Chord.parse('7#5').to_s
    assert_equal 'm7#5', Chord.parse('m7#5').to_s
  end

  def test_all_chords_from_wikibook
    # http://en.wikibooks.org/w/index.php?title=Music_Theory/Complete_List_of_Chord_Patterns
    assert_equal 'maj', Chord.parse_intervals('1 3 5').to_s
    assert_equal '∆', Chord.parse_intervals('1 3 5 7').to_s
    assert_equal '∆9', Chord.parse_intervals('1 3 5 7 9').to_s
    assert_equal '∆13', Chord.parse_intervals('1 3 5 7 9 11 13').to_s
    assert_equal '∆13', Chord.parse_intervals('1 3 5 7 13').to_s
    assert_equal '∆13', Chord.parse_intervals('1 3 7 13').to_s
    assert_equal '69', Chord.parse_intervals('1 3 5 6 9').to_s
    assert_equal '∆#11', Chord.parse_intervals('1 3 5 7 #11').to_s
    assert_equal '∆9#11', Chord.parse_intervals('1 3 5 7 9 #11').to_s
    assert_equal '∆13#11', Chord.parse_intervals('1 3 5 7 9 #11 13').to_s
    assert_equal '∆b13', Chord.parse_intervals('1 3 5 7 b13').to_s
    assert_equal '∆9b13', Chord.parse_intervals('1 3 5 7 9 b13').to_s

    assert_equal '7', Chord.parse_intervals('1 3 5 b7').to_s
    assert_equal '9', Chord.parse_intervals('1 3 5 b7 9').to_s
    assert_equal '13', Chord.parse_intervals('1 3 5 b7 9 13').to_s
    assert_equal '7#11', Chord.parse_intervals('1 3 5 b7 #11').to_s
    assert_equal '9#11', Chord.parse_intervals('1 3 5 b7 9 #11').to_s

    assert_equal '7b9', Chord.parse_intervals('1 3 5 b7 b9').to_s
    assert_equal '7#9', Chord.parse_intervals('1 3 5 b7 #9').to_s
    assert_equal '7b9#9', Chord.parse_intervals('1 3 5 b7 b9 #9').to_s
    assert_equal '7alt', Chord.parse_intervals('1 3 5 b7 b9 #9 b13').to_s

    assert_equal 'sus4', Chord.parse_intervals('1 4 5').to_s
    assert_equal 'sus2', Chord.parse_intervals('1 2 5').to_s
    assert_equal 'sus4add9', Chord.parse_intervals('1 2 4 5').to_s
    assert_equal '∆sus4', Chord.parse_intervals('1 4 5 7').to_s
    assert_equal '7sus4', Chord.parse_intervals('1 4 5 b7').to_s
    assert_equal 'sus4b9', Chord.parse_intervals('1 4 5 b9').to_s

    assert_equal 'm', Chord.parse_intervals('1 b3 5').to_s
    assert_equal 'm7', Chord.parse_intervals('1 b3 5 b7').to_s
    assert_equal 'm∆', Chord.parse_intervals('1 b3 5 7').to_s
    assert_equal 'm∆9', Chord.parse_intervals('1 b3 5 7 9').to_s
    assert_equal 'm∆9b13', Chord.parse_intervals('1 b3 5 7 9 b13').to_s
    assert_equal 'm6', Chord.parse_intervals('1 b3 5 6').to_s
    assert_equal 'm9', Chord.parse_intervals('1 b3 5 b7 9').to_s
    assert_equal 'm11', Chord.parse_intervals('1 b3 5 b7 9 11').to_s
    assert_equal 'm13', Chord.parse_intervals('1 b3 5 b7 9 11 13').to_s
    assert_equal 'm13', Chord.parse_intervals('1 b3 5 b7 11 13').to_s
    assert_equal 'm13', Chord.parse_intervals('1 b3 5 b7 13').to_s

    assert_equal 'º', Chord.parse_intervals('1 b3 b5').to_s
    assert_equal 'º7', Chord.parse_intervals('1 b3 b5 bb7').to_s
    assert_equal 'm7b5', Chord.parse_intervals('1 b3 b5 b7').to_s
    assert_equal 'ºb9', Chord.parse_intervals('1 b3 b5 b9').to_s
    assert_equal 'º7b9', Chord.parse_intervals('1 b3 b5 bb7 b9').to_s
    assert_equal 'm7b5b9', Chord.parse_intervals('1 b3 b5 b7 b9').to_s

    assert_equal '+', Chord.parse_intervals('1 3 #5').to_s
    assert_equal '7#5', Chord.parse_intervals('1 3 #5 b7').to_s
    assert_equal '5', Chord.parse_intervals('1 5').to_s
  end

end
