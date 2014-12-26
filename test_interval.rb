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
end
