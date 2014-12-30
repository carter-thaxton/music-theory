require 'test/unit'
require 'music-theory'

class TestNote < Test::Unit::TestCase
  include MusicTheory

  def test_basics
    c = Note.C
    assert_equal 0, c.diatonic_index
    assert_equal 0, c.accidentals

    fs = Note.Fs
    assert_equal 3, fs.diatonic_index
    assert_equal 1, fs.accidentals

    bb = Note.Bb
    assert_equal 6, bb.diatonic_index
    assert_equal -1, bb.accidentals
  end

  def test_parse
    assert_equal Note.A, Note.parse("A")
    assert_equal Note.Bb, Note.parse("Bb")
    assert_equal Note.Gs(5), Note.parse("G#5")
    assert_equal Note.B(2).sharp(3), Note.parse("B###2")
  end

  def test_octave
    assert_nil Note.C.octave
    assert_equal 4, Note.C(4).octave
  end

  def test_equality
    assert_not_equal Note.C, Note.Cs
    assert_equal Note.C(4), Note.C(4)
    assert_not_equal Note.C(4), Note.C(5)
    assert_equal Note.C, Note.C(4)
    assert_equal Note.C(4), Note.C
    assert_equal Note.C(5), Note.C(4) + Interval.octave
    assert_not_equal Note.C(5), Note.C(4) + Interval.octave(2)
  end

  def test_chromatic_index
    assert_equal 0, Note.C.chromatic_index
    assert_equal 1, Note.Cs.chromatic_index
    assert_equal 1, Note.Db.chromatic_index
    assert_equal 1, Note.C.sharp.chromatic_index
    assert_equal 2, Note.C.sharp(2).chromatic_index
    assert_equal -1, Note.C.flat.chromatic_index
    assert_equal 11, Note.B.chromatic_index
    assert_equal 12, Note.B.sharp.chromatic_index
    assert_equal 13, Note.B.sharp(2).chromatic_index
  end

  def test_interval_addition_and_subtraction
    assert_equal Note.C, Note.C + 0
    assert_equal Note.D, Note.C + 1
    assert_equal Note.C, Note.C + Interval.unison
    assert_equal Note.D, Note.C + Interval.major(2)
    assert_equal Note.Db, Note.C + Interval.minor(2)
    assert_equal Note.Fs, Note.E + Interval.major(2)
    assert_equal Note.E, Note.A + Interval.perfect(5)
    assert_equal Note.Cb, Note.B.sharp(56) + Interval.diminished(2, 57)
    assert_equal Note.G, Note.D - Interval.perfect(5)
    assert_equal Note.Gs, Note.D - Interval.diminished(5)
    assert_equal Note.Gs, Note.D + Interval.diminished(-5)
    assert_equal Note.Gs, -Interval.diminished(5) + Note.D
    assert_equal Note.Gs, Interval.diminished(-5) + Note.D
  end

  def test_subtract_notes
    assert_equal Interval.unison, Note.C - Note.C
    assert_equal Interval.perfect(5), Note.G - Note.C
    assert_equal Interval.perfect(4), Note.C - Note.G
    assert_equal Interval.perfect(5), Note.G(4) - Note.C(4)
    assert_equal Interval.perfect(-5), Note.C(4) - Note.G(4)
    assert_equal Interval.perfect(12), Note.G(5) - Note.C(4)
    assert_equal Interval.diminished(5), Note.F - Note.B
    assert_equal Interval.augmented(4), Note.B - Note.F
    assert_equal Interval.augmented(5, 2), Note.Gs - Note.Cb
  end

  def test_measure_to
    assert_equal Interval.unison, Note.C.measure_to(Note.C)
    assert_equal Interval.perfect(5), Note.C.measure_to(Note.G)
    assert_equal Interval.octave, Note.C(4).measure_to(Note.C(5))
    assert_equal Interval.octave(-1), Note.C(5).measure_to(Note.C(4))
  end

end
