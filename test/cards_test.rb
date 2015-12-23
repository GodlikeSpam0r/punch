require_relative 'config'

class CardsTest < PunchTest
  def setup
    super
    @custom_cards = {
      :cards => {
        :bikini => { :title => 'Bikini' },
        :bottom => { :name => 'Patrick Star' }
      }
    }
  end

  # See test/.punchrc
  def test_test_card_is_loaded
    assert_equal 'Spongebob Squarepants', Punch.config.name
  end

  def test_punch_loads_given_card
    config @custom_cards do
      punch 'bikini 8-10'
      assert_punched 'Bikini'
      assert_punched '08:00-10:00'
    end
  end

  def test_punch_loads_multiple_cards
    config @custom_cards do
      punch 'bikini bottom 14-16'
      assert_punched 'Bikini'
      assert_punched 'Patrick Star'
      assert_punched '14:00-16:00'
    end
  end
end
