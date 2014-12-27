require 'test/unit'
require 'music-theory'

class TestInterval < Test::Unit::TestCase
  include MusicTheory

  def test_generic
    assert_equal 2, Interval.new(2).number
    assert Interval.new(2).generic?
    assert_equal Interval.new(2), Interval.major(2)
  end

  def test_helpers
    assert Interval.major(3).major?
    assert !Interval.major(3).minor?
    assert Interval.diminished(3).diminished?
    assert Interval.octave(3).octave?
    assert !Interval.unison.octave?
    assert Interval.unison.octave_or_unison?
    assert Interval.octave.octave_or_unison?
  end

  def test_validations
    assert_raises(Interval::InvalidIntervalError) { Interval.major(5) }
    assert_raises(Interval::InvalidIntervalError) { Interval.perfect(3) }
    assert_raises(Interval::InvalidIntervalError) { Interval.new(2, :junk) }
  end

  def test_fixnum
    assert_equal(Interval.unison, 0.to_interval)
    assert_equal(Interval.major(2), 1.to_interval)
    assert_equal(Interval.octave, 7.to_interval)
    assert_equal(Interval.octave(-1), -7.to_interval)
  end

  def test_interval_strings
    assert_equal("major 3rd", Interval.major(3).to_s)
    assert_equal("major 2nd", Interval.major(2).to_s)
    assert_equal("unison", Interval.unison.to_s)
    assert_equal("octave", Interval.octave.to_s)
    assert_equal("down octave", Interval.octave(-1).to_s)
    assert_equal("down 2 octaves", Interval.octave(-2).to_s)
    assert_equal("diminished octave", Interval.diminished(8).to_s)
    assert_equal("double-diminished octave", Interval.double_diminished(8).to_s)
  end

  def test_interval_shorthand
    assert_equal("M3", Interval.major(3).shorthand)
    assert_equal("M2", Interval.major(2).shorthand)
    assert_equal("P1", Interval.unison.shorthand)
    assert_equal("P8", Interval.octave.shorthand)
    assert_equal("-P8", Interval.octave(-1).shorthand)
    assert_equal("-P15", Interval.octave(-2).shorthand)
    assert_equal("d8", Interval.diminished(8).shorthand)
    assert_equal("dd8", Interval.double_diminished(8).shorthand)
  end

  def test_semitones
    assert_equal 0, Interval.unison.semitones

    assert_equal 12, Interval.octave.semitones
    assert_equal -12, Interval.octave(-1).semitones

    assert_equal 1, Interval.minor(2).semitones
    assert_equal 2, Interval.major(2).semitones
    assert_equal 3, Interval.minor(3).semitones
    assert_equal 4, Interval.major(3).semitones
    assert_equal 5, Interval.perfect(4).semitones
    assert_equal 6, Interval.augmented(4).semitones
    assert_equal 7, Interval.perfect(5).semitones
    assert_equal 8, Interval.minor(6).semitones
    assert_equal 9, Interval.major(6).semitones
    assert_equal 10, Interval.minor(7).semitones
    assert_equal 11, Interval.major(7).semitones

    assert_equal 13, Interval.minor(9).semitones
    assert_equal 14, Interval.major(9).semitones

    assert_equal -13, Interval.minor(-9).semitones
    assert_equal -14, Interval.major(-9).semitones
  end

  def test_augmented
    assert_equal 3, Interval.augmented(2).semitones
    assert_equal 5, Interval.augmented(3).semitones
    assert_equal 6, Interval.augmented(4).semitones
    assert_equal 8, Interval.augmented(5).semitones
    assert_equal 10, Interval.augmented(6).semitones
    assert_equal 12, Interval.augmented(7).semitones
    assert_equal 13, Interval.augmented(8).semitones
  end

  def test_diminished
    assert_equal 0, Interval.diminished(2).semitones
    assert_equal 2, Interval.diminished(3).semitones
    assert_equal 4, Interval.diminished(4).semitones
    assert_equal 6, Interval.diminished(5).semitones
    assert_equal 7, Interval.diminished(6).semitones
    assert_equal 9, Interval.diminished(7).semitones
    assert_equal 11, Interval.diminished(8).semitones
  end

  def test_double_augmented
    assert_equal 4, Interval.double_augmented(2).semitones
    assert_equal 6, Interval.double_augmented(3).semitones
    assert_equal 7, Interval.double_augmented(4).semitones
    assert_equal 9, Interval.double_augmented(5).semitones
    assert_equal 11, Interval.double_augmented(6).semitones
    assert_equal 13, Interval.double_augmented(7).semitones
    assert_equal 14, Interval.double_augmented(8).semitones
  end

  def test_double_diminished
    assert_equal -1, Interval.double_diminished(2).semitones
    assert_equal 1, Interval.double_diminished(3).semitones
    assert_equal 3, Interval.double_diminished(4).semitones
    assert_equal 5, Interval.double_diminished(5).semitones
    assert_equal 6, Interval.double_diminished(6).semitones
    assert_equal 8, Interval.double_diminished(7).semitones
    assert_equal 10, Interval.double_diminished(8).semitones
    assert_equal 11, Interval.double_diminished(9).semitones
  end

  def test_special_unisons
    assert_equal 1, Interval.augmented(1).semitones
    assert_equal -1, Interval.diminished(1).semitones
    assert_equal -1, Interval.augmented(-1).semitones
    assert_equal 1, Interval.diminished(-1).semitones

    assert_equal 2, Interval.double_augmented(1).semitones
    assert_equal -2, Interval.double_diminished(1).semitones
    assert_equal -2, Interval.double_augmented(-1).semitones
    assert_equal 2, Interval.double_diminished(-1).semitones

    assert_equal Interval.diminished(-1), Interval.diminished(-1)
    assert_not_equal Interval.diminished(-1), Interval.diminished(1)
    assert_equal Interval.double_diminished(-1), Interval.double_diminished(-1)
    assert_not_equal Interval.double_diminished(-1), Interval.double_diminished(1)
  end

  def test_tritones
    assert_equal 6, Interval.tritone.semitones
    assert_equal 0, Interval.tritone(0).semitones
    assert_equal 12, Interval.tritone(2).semitones
    assert_equal Interval.tritone(2), Interval.octave
    assert_equal Interval.tritone(-4), Interval.octave(-2)
  end

end
