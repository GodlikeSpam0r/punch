class Month
  include Totals

  NEWLINE = "\r\n"

  NAMES = {
    1  => 'januar',
    2  => 'februar',
    3  => 'maerz',
    4  => 'april',
    5  => 'mai',
    6  => 'juni',
    7  => 'juli',
    8  => 'august',
    9  => 'september',
    10 => 'oktober',
    11 => 'november',
    12 => 'dezember',
  }

  attr_accessor :name, :days

  def self.name(month_nr)
    NAMES[month_nr]
  end

  def initialize(name)
    @name = name
  end

  def newline
    NEWLINE
  end

  def to_s(options = {})
    color = options.fetch :color, false
    days.sort!
    b_count = max_block_count
    "#{name}#{newline * 2}#{
      days.map { |d|
        d.to_s(:color => color, :padding => b_count)
      }.join(newline)
    }#{newline * 2}Total: #{total_str}#{newline}"
  end

  def colored
    to_s :color => true
  end

  def children
    days
  end

  def blocks
    days.flat_map &:blocks
  end

  def max_block_count
    days.map(&:block_count).max
  end
end
