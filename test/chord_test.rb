require 'test/unit'
require 'music-theory'

class ChordTest < Test::Unit::TestCase
  include MusicTheory

  def test_major
    c = Chord.parse('C')
    assert_equal Note.C, c.root
    assert_equal 3, c.length
    assert_equal [Note.C, Note.E, Note.G], c.notes
    assert_equal :major, c.quality
  end

  # def test_minor
  #   cm = Chord.parse('Cm')
  #   assert_equal Note.C, cm.root
  #   assert_equal 3, cm.length
  #   assert_equal [Note.C, Note.Eb, Note.G], cm.notes
  #   assert_equal :minor, cm.quality
  # end

end
