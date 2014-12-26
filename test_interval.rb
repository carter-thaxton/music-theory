require 'test/unit'
require './interval'
require './note'

class TestInterval < Test::Unit::TestCase

  def test_fixnum
    assert_equal(Interval.unison, 0.to_interval)
    assert_equal(Interval.one_based(2), 1.to_interval)
    assert_equal("octave", 7.to_interval.to_s)
    assert_equal("down octave", -7.to_interval.to_s)
  end

  def test_interval_strings
    assert_equal("major 3rd", Interval.major(3).to_s)
    assert_equal("major 2nd", Interval.major(2).to_s)
    assert_equal("unison", Interval.unison.to_s)
    assert_equal("octave", Interval.octave.to_s)
    assert_equal("down octave", Interval.octave(-1).to_s)
    assert_equal("down 2 octaves", Interval.octave(-2).to_s)
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

  def test_semitones
    assert_equal 0, Interval.unison.semitones

    assert_equal 12, Interval.octave.semitones
    assert_equal -12, Interval.octave(-1).semitones

    assert_equal 1, Interval.minor(2).semitones
    assert_equal 2, Interval.major(2).semitones
    assert_equal 3, Interval.minor(3).semitones
    assert_equal 4, Interval.major(3).semitones
    assert_equal 5, Interval.perfect(4).semitones
    assert_equal 6, Interval.tritone.semitones
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

  def test_special_unisons
    assert_equal 1, Interval.augmented(1).semitones
    assert_equal -1, Interval.diminished(1).semitones
    assert_equal -1, Interval.augmented(-1).semitones
    assert_equal 1, Interval.diminished(-1).semitones

    assert_equal Interval.diminished(-1), Interval.diminished(-1)
    assert_not_equal Interval.diminished(-1), Interval.diminished(1)
  end

  def test_tritones
    assert_equal 6, Interval.tritone.semitones
    assert_equal 0, Interval.tritone(0).semitones
    assert_equal 12, Interval.tritone(2).semitones
    assert_equal Interval.tritone(2), Interval.octave
    assert_equal Interval.tritone(-4), Interval.octave(-2)
  end

end
