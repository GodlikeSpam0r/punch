class RemoveTest < PunchTest
  # Travel to 28.01.2015. So the current BRF month is February.
  def setup
    Timecop.freeze(Time.new(2015, 01, 28))
  end

  def test_removing_at_end
    brf_write %{
      Februar 2015

      01.02.15   08:00-12:00   Total: 04:00

      Total: 04:00
    }

    punch '--remove 11:30-12'
    assert_punched '01.02.15   08:00-11:30   Total: 03:30'
  end

  def test_removing_at_start
    brf_write %{
      Februar 2015

      01.02.15   08:00-12:00   Total: 04:00

      Total: 04:00
    }

    punch '--remove 8-11'
    assert_punched '01.02.15   11:00-12:00   Total: 01:00'
  end

  def test_splitting
    brf_write %{
      Februar 2015

      01.02.15   08:00-12:00   Total: 04:00

      Total: 04:00
    }

    punch '--remove 9-10'
    assert_punched '01.02.15   08:00-09:00 10:00-12:00   Total: 03:00'
  end

  def teardown
    clear_hours_folder
  end
end