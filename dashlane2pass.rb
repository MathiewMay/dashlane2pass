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

def store(title, email, data)
  command = "pass insert -m 'Dashlane/#{title}/#{email}' > /dev/null"
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
    username, username2, username3, title, password, note, url, category, otpSecret, = row
        if title.to_s.strip.empty?
            newTitle = url.split("/")
            title = newTitle[2]
        end
    store(title, username, [password, "Username: #{username2}"])
end
