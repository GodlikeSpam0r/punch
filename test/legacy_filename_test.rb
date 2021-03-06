require_relative 'config'

class LegacyFilenameTest < PunchTest
  def setup
    @legacy_filename = "#{Punch.config.hours_folder}/november_2013.txt"
    @new_filename = "#{Punch.config.hours_folder}/2013-11.txt"

    File.open(@legacy_filename, 'w:UTF-8') do |f|
      f.puts "November 2013 - Spongebob\r\n\r\n"
      f.puts '29.11.13   08:00-16:44   Total: 99:99'
    end
  end

  def test_reads_legacy_file_if_no_new_file_present
    punch '--month 11.13'
    assert_punched '29.11.13   08:00-16:44'
  end

  def test_renames_legacy_file_to_new_format
    assert File.exist?(@legacy_filename), 'This should not happen™'
    punch '--month 11.13'
    refute File.exist?(@legacy_filename), 'Moving legacy file failed.'
    assert File.exist?(@new_filename), 'Moving legacy file failed.'
  end

  def test_ignores_legacy_file_if_new_file_present
    File.open(@new_filename, 'w:UTF-8') do |f|
      f.puts "November 2013 - Radi\r\n\r\n"
      f.puts '14.11.13   03:00-05:00   Total: 02:00'
    end

    punch '--month 11.13'
    assert_punched '14.11.13   03:00-05:00'

    assert File.exist?(@legacy_filename), 'Deleted legacy file.'
  end

  def test_renames_legacy_file_from_march
    legacy_filename = "#{Punch.config.hours_folder}/maerz_2015.txt"
    new_filename = "#{Punch.config.hours_folder}/2015-3.txt"

    File.open(legacy_filename, 'w:UTF-8') do |f|
      f.puts "Maerz 2013 - Spongebob\r\n\r\n"
      f.puts '29.11.13   08:00-16:44   Total: 99:99'
    end

    punch '--month 3.15'
    refute File.exist?(legacy_filename), 'Moving legacy file failed.'
    assert File.exist?(new_filename), 'Moving legacy file failed.'
  end
end
