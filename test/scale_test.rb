require 'test/unit'
require 'music-theory'

class ScaleTest < Test::Unit::TestCase
  include MusicTheory

  def test_major_scale
    s = Scale.major
    assert_equal 7, s.length
    assert_equal Interval.unison, s[0]
    assert_equal Interval.major(2), s[1]
    assert_equal Interval.major(3), s[2]
    assert_equal Interval.perfect(4), s[3]
    assert_equal Interval.perfect(5), s[4]
    assert_equal Interval.major(6), s[5]
    assert_equal Interval.major(7), s[6]
  end

  def test_natural_minor_scale
    s = Scale.natural_minor
    assert_equal 7, s.length
    assert_equal Interval.unison, s[0]
    assert_equal Interval.major(2), s[1]
    assert_equal Interval.minor(3), s[2]
    assert_equal Interval.perfect(4), s[3]
    assert_equal Interval.perfect(5), s[4]
    assert_equal Interval.minor(6), s[5]
    assert_equal Interval.minor(7), s[6]
  end

  def test_interval
    assert_equal Interval.unison, Scale.major.interval(1)
    assert_equal Interval.major(2), Scale.major.interval(2)
    assert_equal Interval.major(9), Scale.major.interval(9)
    assert_equal [Interval.unison, Interval.major(3), Interval.perfect(5)], Scale.major.interval([1, 3, 5])
  end

  def test_with_roots
    s = Scale.major.with_root(Note.A)
    assert_equal Note.A, s[0]
    assert_equal Note.B, s[1]
    assert_equal Note.Cs, s[2]
  end

  def test_rotate
    assert_equal "1 2 b3 4 5 6 b7", Scale.major.rotate(1).intervals_s
    assert_equal "1 2 3 4 5 6 7", Scale.major.rotate(7).intervals_s
    assert_equal "1 2 3 4 5 6 7", Scale.major.rotate(14).intervals_s
  end

  def test_transpose
    assert_equal Note.A.major, Note.C.major.transpose(Interval.minor(-3))
    assert_equal Note.A.major, Note.C.major - Interval.minor(3)
    assert_raises { Scale.major + Interval.major(3) }
  end

end
