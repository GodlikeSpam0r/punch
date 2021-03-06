Punch.configure do |config|
  config.name = 'Spongebob Squarepants'

  config.language = :de

  config.hand_in_date = 20

  config.cards = {
    :test => {
      :hours_folder => TEST_HOURS_FOLDER,
      :out => TestOut,
      :in => TestIn,
      :debug => true,
      :clear_buffer_before_punch => false
    }
  }
end
