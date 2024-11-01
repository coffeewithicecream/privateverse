require_relative 'config'
require_relative 'requester'

class MegaverseEntity
  class MegaverseEntityError < StandardError; end

  @url = ''

  def self.create (row, column, extra_arg=nil)
    raise ArgumentError, "Row and Column must be positive numbers" unless row >= 0 && column >= 0

    # Create the request payload (arguments)
    payload = {
      candidateId: Config::CANDIDATE_ID,
      row: row,
      column: column
    }

    if extra_arg
      if extra_arg.is_a?(Hash)
        payload.merge!(extra_arg)
      else
        raise ArgumentError, "Extra arguments should be in a hash format"
      end
    end

    begin
      Requester.postPayload(@url, payload.to_json)
    rescue StandardError => e
      raise MegaverseEntityError, "An error occurred sending the HTTP request: #{e.message}"
    end
    payload.to_json
  end
end
