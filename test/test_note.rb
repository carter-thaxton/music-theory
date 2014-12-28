require 'test/unit'
require 'music-theory'

class TestNote < Test::Unit::TestCase
  include MusicTheory

  def test_basics
    c = Note.C
    assert_equal 0, c.diatonic_index
    assert_equal 0, c.accidentals
    assert_equal 4, c.octave

    fs = Note.Fs
    assert_equal 3, fs.diatonic_index
    assert_equal 1, fs.accidentals
    assert_equal 4, fs.octave

    bb = Note.Bb
    assert_equal 6, bb.diatonic_index
    assert_equal -1, bb.accidentals
    assert_equal 4, bb.octave
  end

  def test_interval_addition
    assert_equal Note.C, Note.C + 0
    assert_equal Note.D, Note.C + 1
    assert_equal Note.C, Note.C + Interval.unison
    assert_equal Note.D, Note.C + Interval.major(2)
#    assert_equal Note.Db, Note.C + Interval.minor(2)
#    assert_equal Note.Fs, Note.E + Interval.major(2)
  end

end
