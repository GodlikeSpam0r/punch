module OS
  module_function

  # http://stackoverflow.com/a/171011/1314848.
  def windows?
    !!(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ ruby_platform)
  end

  def unix?
    !windows?
  end

  def mac?
    !!(/darwin/ =~ ruby_platform)
  end

  def linux?
    unix? && !mac?
  end

  def open(str)
    system "#{open_cmd} #{str}"
  end

  def open_cmd
    case
    when mac?
      'open'
    when linux?
      'xdg-open'
    else
      'vi'
    end
  end

  def ruby_platform
    RUBY_PLATFORM
  end
end