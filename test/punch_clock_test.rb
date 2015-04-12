class PunchClockTest < PunchTest

  # Travel to 28.01.2015. So the current BRF month is February.
  def setup
    Timecop.freeze(Time.new(2015, 01, 28))
  end

  def test_nice_hint_when_being_dumb
    punch "--i'm so dumb"
    assert_includes output, 'punch -h'
  end

  def test_without_args_prints_month
    punch '8-12 13-17'
    punch
    content = brf_content
    assert_includes content, 'Februar'
    assert_includes content, '2015'
    assert_includes content, 'Total: 08:00'
  end

  def test_today_is_always_listed_in_output_but_not_in_brf
    punch # empty month
    date = '28.01.15'
    refute_includes brf_content, date
    assert_includes output, date
  end

  def test_add_one_block
    punch '18-19'
    assert_includes brf_content, '28.01.15   18:00-19:00   Total: 01:00'
  end

  def test_add_multiple_blocks
    punch '9-12 12:30-17 22-23'
    assert_includes brf_content,
      '28.01.15   09:00-12:00   12:30-17:00   22:00-23:00   Total: 08:30'
  end

  def test_add_block_over_midnight
    punch '23-04'
    assert_includes brf_content, '28.01.15   23:00-04:00   Total: 05:00'
  end

  def test_day_flag
    punch '-d 02.02.15 14-15:45'
    assert_includes brf_content, '02.02.15   14:00-15:45   Total: 01:45'
  end

  def test_yesterday_switch
    punch '-y 11-13'
    assert_includes brf_content, '27.01.15   11:00-13:00   Total: 02:00'
  end

  def test_format_switch_normalizes_whitespace
    brf_write %{
      Februar 2015

        01.02.15 08:00-09:00  12:00-13:30                       Total: 02:30

      Total: 01:30
    }

    punch '-f'

    assert_includes brf_content,
      '01.02.15   08:00-09:00   12:00-13:30   Total: 02:30'
  end

  def test_format_switch_recalculates_totals
    brf_write %{
      Februar 2015

      01.02.15   08:00-09:00   12:00-13:30   Total: 22:00

      Total: 00:00
    }

    punch '-f'

    assert_includes brf_content,
      '01.02.15   08:00-09:00   12:00-13:30   Total: 02:30'
  end

  def test_format_gets_rid_of_empty_days
    brf_write %{
      Februar 2015 - Rathesan Iyadurai

      22.01.15   15:00-15:30                 Total: 00:30
      24.01.15
      25.01.15   13:00-13:15   16:20-17:00   Total: 00:55

      Total: 01:25
    }

    punch '-f'

    refute_includes brf_content, '24.03.15'
  end

  def test_format_gets_rid_of_empty_blocks
    brf_write %{
      Februar 2015 - Rathesan Iyadurai

      25.01.15   00:00-00:00   16:20-17:00   Total: 00:40

      Total: 00:40
    }

    punch '-f'

    refute_includes brf_content, '00:00-00:00'
  end

  def test_format_gets_rid_of_days_with_only_empty_blocks
    brf_write %{
      Februar 2015 - Rathesan Iyadurai

      03.01.15   00:00-00:00                 Total: 00:00

      Total: 00:00
    }

    punch '-f'

    refute_includes brf_content, '03.01.15'
  end

  def test_punch_previous_month_with_previous_switch
    punch "-p 2-3"

    assert_includes brf_content, "Januar 2015"
  end

  def test_punch_next_month_with_next_switch
    punch "-n 2-3"

    assert_includes brf_content, "Maerz 2015"
  end

  def teardown
    clear_hours_folder
  end

end
