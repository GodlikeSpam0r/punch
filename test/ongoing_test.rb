require_relative 'config'

class OngoingTest < PunchTest

  def test_add_ongoing_block
    punch '12'
    assert_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  def test_add_ongoing_block_and_block
    punch '12 13:30-15'
    assert_punched '28.01.15   12:00-12:00   13:30-15:00   Total: 01:30'
  end

  def test_complete_ongoing_block
    punch '12'
    punch '14'
    assert_punched '28.01.15   12:00-14:00   Total: 02:00'
  end

  def test_start_ongoing_in_existing_block
    punch '13-15'
    punch '14'
    assert_punched '28.01.15   13:00-15:00   Total: 02:00'
  end

  def test_end_ongoing_block_started_in_existing_block
    punch '13-15'
    punch '14'
    punch '18'
    assert_punched '28.01.15   13:00-15:00   18:00-18:00   Total: 02:00'
  end

  def test_shadow_block_with_complete
    punch '13-13:30 12'
    punch '14'
    assert_punched '28.01.15   12:00-14:00   Total: 02:00'
  end

  def test_overlap_block_with_complete
    punch '12 14-15'
    punch '14:30'
    assert_punched '28.01.15   12:00-15:00   Total: 03:00'
  end

  def test_remove
    punch '12'
    punch '--remove 11-13'
    refute_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  def test_remove_with_ongoing_block_arg
    punch '12'
    punch '-r 12'
    refute_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  def test_format_removes_ongoing_blocks
    punch '12'
    punch '--format'
    refute_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  def test_raw_switch_doesnt_remove_ongoing_blocks
    punch "12"
    punch "--raw"
    assert_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  def test_irrelevant_remove_doesnt_remove_ongoing_blocks
    punch "12"
    punch "--remove 20-21"
    assert_punched '28.01.15   12:00-12:00   Total: 00:00'
  end

  # This is not really a feature and is only here to make sure that the second
  # half block doesn't complete the first one.
  def test_start_multiple_ongoing_blocks_cant_complete_themselves
    punch '12 13'
    assert_punched '12:00-12:00   13:00-13:00'
  end

  # Again, not really a feature, but here to test consistency. Punch is not
  # intended to be used like this.
  def test_multiple_complete_takes_last_complete
    punch '0915'
    assert_punched '09:15-09:15'

    punch '13 1330'
    assert_punched '09:15-13:30'
  end

end
