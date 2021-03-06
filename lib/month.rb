# frozen_string_literal: true

class Month
  include Totals
  include Comparable

  NEWLINE = OS.windows? ? "\r\n" : "\n"

  attr_accessor :days, :number, :year
  attr_writer :name

  alias_method :month, :number

  # @param brf_str [String]
  # @param month_nr [Integer]
  # @param year [Integer]
  # @return [Month]
  def self.from(brf_str, month_nr, year)
    month        = BRFParser.new.parse(brf_str)
    month.number = month_nr
    month.year   = year
    month
  end

  # Like .from, but will infer the month and year from the file name.
  #
  # @param file_path [String] absolute path to BRF file
  # @return [Month]
  def self.from_file(file_path)
    basename = File.basename(file_path, '.txt')
    brf_str = File.read(file_path)
    from brf_str, *basename.split('-').map(&:to_i).reverse
  end

  def initialize(name)
    @name = name
    @days = []
  end

  def newline
    NEWLINE
  end

  def name
    return @name if year.nil? || number.nil?

    name = +"#{MonthNames.name(number).capitalize} #{year}"
    name << " - #{Punch.config.name}" unless Punch.config.name.empty?
    name.prepend("#{Punch.config.title} - ") unless Punch.config.title.empty?
    name
  end

  def add(*new_days)
    new_days.each do |day|
      if (existing = days.find { |d| d.date == day.date })
        existing.add(*day.blocks)
      else
        days << day
      end
    end
  end

  def to_s(options = {})
    days.sort!
    b_count = max_block_count
    day_options = options.merge :padding => b_count
    days_str = days.map do |d|
      day_str = +d.to_s(day_options)

      if (days.first != d) && options[:group_weeks] && d.monday?
        day_str.prepend("\n")
      end

      day_str
    end.join(newline)

    "#{name}#{newline * 2}#{days_str}#{newline * 2}" \
      "Total: #{total_str}#{newline}"
  end

  # @param date_args [String]
  # @return [Array<Day>]
  def find_or_create_days_from_dates(date_args)
    dates = [date_args]
    dates = date_args.split(',') if date_args.include?(',')
    dates = dates.inject([]) do |new_dates, date|
      if date.include?('-')
        range = Range.new(*date.split('-'))
        new_dates.push(*range.to_a)
      else
        new_dates.push(date)
      end
    end

    dates.map do |date|
      day_nr, month_nr, year_nr = date.split('.')

      day = days.find do |d|
        (day_nr   ? d.day?(day_nr)     : true) &&
        (month_nr ? d.month?(month_nr) : true) &&
        (year_nr  ? d.year?(year_nr)   : true)
      end

      if day.nil?
        day = DateParser.parse(date, self)
        add day
      else
        day
      end

      day
    end
  end

  def month_year
    @month_year ||= MonthYear.new(:month => number, :year => year)
  end

  def prev_month_year
    month_year.prev
  end

  def next_month_year
    month_year.next
  end

  def to_date
    month_year.date
  end

  def fancy
    to_s :fancy => true
  end

  def full
    full_month.to_s(
      :fancy => true,
      :prepend_name => true,
      :group_weeks => Punch.config.group_weeks_in_interactive_mode
    )
  end

  def full_month
    @full_month ||= FullMonth.new(self).full_month
  end

  # @return [Stats]
  def stats
    @stats ||= Stats.new(self)
  end

  def workdays
    full_month.days.select(&:workday?)
  end

  def children
    days
  end

  def blocks
    days.flat_map(&:blocks)
  end

  def max_block_count
    days.map(&:block_count).max
  end

  def short_year
    year % 100
  end

  def cleanup!(options = {})
    days.each(&:remove_ongoing_blocks!) if options[:remove_ongoing_blocks]
    days.reject!(&:empty?)
  end

  def <=>(other)
    [year, number] <=> [other.year, other.number]
  end

  def empty?
    days.all?(&:empty?)
  end
end
