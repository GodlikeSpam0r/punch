task :default => :test

desc 'Run test suite.'
task :test do
  require_relative 'test/punch_test'
end

desc 'Link punch.rb to /usr/local/bin.'
task :install do
  if system "ln -sr punch.rb /usr/local/bin/punch"
    puts 'punch.rb sucessfully linked to /usr/local/bin/punch. ' \
      'Try executing "punch".'
  end
end

desc 'Remove punch.rb link from /usr/local/bin.'
task :uninstall do
  if system "rm $(find -L /usr/local/bin -samefile punch.rb)"
    puts "punch.rb sucessfully unlinked from /usr/local/bin."
  end
end
