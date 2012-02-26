require 'minitest/unit'
require 'minitest/autorun'

class ShowThemHowToBeatIt  < MiniTest::Unit::TestCase

  # will fail
  def test_show_them_how_to_funky
    refute_equal("funky", "funky")
  end

  # will pass
  def test_show_them_whats_right
    assert_equal("right", "right")
  end

  # will error
  def test_no_one_wants_to_be_defeated
    raise SyntaxError
  end

  # pending
  def test_better_do_what_you_can
    raise NotImplementedError
  end

  # omit
  def test_just_beat_it
    e = NotImplementedError.new
    #e.set_assertion(true)
    raise e
  end

end
