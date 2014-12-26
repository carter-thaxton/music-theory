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
end
