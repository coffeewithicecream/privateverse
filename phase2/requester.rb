require 'net/http'
require 'json'
require 'uri'
require 'logger'

require_relative 'config'
require_relative 'applogger'

module Requester

  # Raise custom Module Error on failures
  class RequesterError < StandardError; end

  @logger = AppLogger.instance

  def self.getResponseToFile(url, filename)
    unless url.is_a?(String) && URI.parse(url)
      raise ArgumentError, "Please give a valid url"
    end

    # Parse the URL
    begin
      uri = URI(url)
      response = Net::HTTP.get(uri)
      @logger.debug("Response received: #{response}")
    rescue SocketError => e
      raise RequesterError, "Network error: #{e.message}"
    rescue URI::InvalidURIError => e
      raise RequesterError, "Invalid URI: #{e.message}"
    rescue StandardError => e
      raise RequesterError, "An error occurred: #{e.message}"
    end

    # Store the response into a file
    begin
      File.write(filename, response)
      @logger.info("Goal Map successfully written to #{filename}.")
    rescue Errno::EACCES => e
      raise RequesterError, "Permission denied: #{e.message}"
    rescue Errno::ENOENT => e
      raise RequesterError, "File not found: #{e.message}"
    rescue StandardError => e
      raise RequesterError, "An error occurred while writing to the file: #{e.message}"
    end
  end

  def self.postPayload(url, payload)
    unless url.is_a?(String) && URI.parse(url)
      raise ArgumentError, "Please give a valid url"
    end

    unless self.valid_json?(payload)
      raise ArgumentError, "Please give a valid JSON payload"
    end

    uri = URI(url)
    @logger.debug(payload)

    # Create a new HTTP POST request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload

    attempts = 0
    success = false

    while attempts < Config::MAX_RETRIES && !success
      attempts += 1
      begin
        # Execute the request
        response = http.request(request)

        # Check if the response is successful (status 2xx)
        if response.is_a?(Net::HTTPSuccess)
          @logger.info("Request succeeded: #{response.body}")
          success = true  # Exit the loop
        else
          # Check for specific retryable errors like 429 or 500
          if response.code.to_i == 429 || response.code.to_i >= 500
            @logger.warn( "Retryable error, will retry...: #{response.code} - #{response.body}")
          else
            raise RequesterError, "Non-retryable error, aborting: #{response.code} - #{response.body}"
            break
          end
        end

      rescue => e
        raise RequesterError, "Error occurred: #{e.message}"
      end
    end
  end

  def self.valid_json?(json)
    json.is_a?(String) && JSON.parse(json)
  rescue JSON::ParserError
    false
  end
end
