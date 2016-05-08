require_relative 'config'

class StatsTest < PunchTest
  def stats
    Stats.new(current_month)
  end

  def test_longest_day_and_block_stats
    assert_equal '00:00', stats.longest_day
    assert_equal '00:00', stats.longest_block
    assert_equal 0, stats.most_blocks

    punch '8-13'
    assert_equal '05:00', stats.longest_day
    assert_equal '05:00', stats.longest_block
    assert_equal 1, stats.most_blocks
    assert_equal 1, stats.total_days
    assert_equal 1, stats.total_blocks

    punch '-d 27 8-14 16-18'
    assert_equal '08:00', stats.longest_day
    assert_equal '06:00', stats.longest_block
    assert_equal 2, stats.most_blocks
    assert_equal 2, stats.total_days
    assert_equal 3, stats.total_blocks
  end

  def test_total_money_made
    assert_equal 'CHF 0.0', stats.total_money_made

    punch '8-15'

    config :hourly_pay => 9000 do
      assert_equal 'CHF 63000.0', stats.total_money_made
    end

    config :hourly_pay => 18.5 do
      assert_equal 'CHF 129.5', stats.total_money_made
    end
  end

  def test_late_nights
    assert_equal 0, stats.late_nights

    punch '-y 23-3'
    assert_equal 1, stats.late_nights

    punch '22-0:15'
    assert_equal 2, stats.late_nights
  end

  def test_early_mornings
    assert_equal 0, stats.early_mornings

    punch '6-12'
    assert_equal 1, stats.early_mornings
  end
end