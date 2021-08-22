#!/usr/bin/env ruby
require "csv"
require "optparse"

abort("Missing CSV file") if $ARGV.empty?

@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options] filename.csv"

  opts.on("-n", "--dry-run", "Show what would be done only") do |n|
    @options[:dry_run] = n
  end
end.parse!

def store(title, data)
  command = "pass insert -m 'Dashlane/#{title}' > /dev/null"
  puts command

  return if @options[:dry_run]

  IO.popen(command, "w") do |io|
    io.puts data.join("\n")
  end

  if $? == 1
    abort("Command failed: #{command}")
  end
end

CSV.foreach($ARGV[0]) do |row|
  case row.length
  when 9
    username, username2, username3, title, password, note, url, category, otpSecret, = row
    store(title, [password, "Username: #{username2}", "Email: #{username}"])
  else
    STDERR.puts "Skipped: #{row.length}"
  end
end
