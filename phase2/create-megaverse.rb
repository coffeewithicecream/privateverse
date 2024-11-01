#!/usr/bin/env ruby

require 'json'
require 'optparse'

require_relative 'applogger'
require_relative 'config'
require_relative 'requester'
require_relative 'cometh'
require_relative 'soloon'
require_relative 'polyanet'

# Download once the goal file and store it locally for testing
def downloadGoalFile
  logger = AppLogger.instance

  begin
    Requester.getResponseToFile(Config::GOAL_URL, Config::GOAL_FILENAME)
  rescue StandardError => e
    logger.fatal("Error on downloading GoalFile: #{e.message}")
    exit(1)
  end
end

def createMegaverse
  logger = AppLogger.instance

  # Read the JSON data from the file
  begin
    # Attempt to read the file
    content = File.read(Config::GOAL_FILENAME)
  rescue Errno::ENOENT => e
    logger.fatal("File not found: #{e.message}")
    exit(1)
  rescue Errno::EACCES => e
    logger.fatal("Permission denied: #{e.message}")
    exit(1)
  rescue StandardError => e
    logger.fatal("An error occurred while reading the file: #{e.message}")
    exit(1)
  end

  # Parse the JSON data into a Ruby hash
  begin
    data = JSON.parse(content)
  rescue JSON::ParserError => e
    logger.fatal("Failed to parse JSON: #{e.message}")
    exit(1)
  end

  # Output the parsed data
  begin
    data["goal"].each_with_index do |row, i|
      row.each_with_index do |key, j|
        if key == "POLYANET"
          Polyanet.create(i,j)
        elsif key.end_with?("SOLOON")
          Soloon.create(i,j, { color: key.delete_suffix!('_SOLOON').downcase! })
        elsif key.end_with?("COMETH")
          Cometh.create(i,j, { direction: key.delete_suffix!('_COMETH').downcase! })
        end
      end
      # Seconds to wait before the next iteration since a rate limit exists
      sleep Config::RATE_LIMIT_DELAY_SECS
    end
  rescue StandardError => e
    logger.error(e.message)
    exit(1)
  end
end

logger = AppLogger.instance

# Initialize options hash
options = {}

# Define options
OptionParser.new do |opts|
  opts.banner = "Usage: create-megaverse.rb [options]"

  opts.on('-f', '--from-source', 'Download Goal Map from source') do
    options[:download] = true
  end

  opts.on('-d', '--debug', 'Enable debug mode') do
    options[:debug] = true
  end
end.parse!

if options[:debug]
  logger.level = Logger::DEBUG
end

if options[:download]
  logger.debug("Downlaoding Goal file from source...")
  downloadGoalFile
end

createMegaverse
