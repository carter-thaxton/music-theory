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
    assert_equal 'major', Chord.parse('').to_s
    assert_equal 'C', Chord.parse('C').to_s
    assert_equal 'Cm', Chord.parse('Cm').to_s
    assert_equal 'Cm7b5', Chord.parse('Cm7b5').to_s
    assert_equal 'Cm7b5', Chord.parse('Cø').to_s
  end

end
