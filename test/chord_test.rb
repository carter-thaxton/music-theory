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
  end

  def test_quality
    assert_equal :major, Chord.major.quality
    assert_equal :minor, Chord.minor.quality
    assert_equal :augmented, Chord.augmented.quality
    assert_equal :diminished, Chord.diminished.quality
  end

  def test_alterations
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

  # def test_minor
  #   cm = Chord.parse('Cm')
  #   assert_equal Note.C, cm.root
  #   assert_equal 3, cm.length
  #   assert_equal [Note.C, Note.Eb, Note.G], cm.notes
  #   assert_equal :minor, cm.quality
  # end

end
