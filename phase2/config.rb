module Config
  CANDIDATE_ID = "5a1a4b3a-dba0-4857-9d06-a6b628e6b2f2"
  RATE_LIMIT_DELAY_SECS = 2
  MAX_RETRIES = 5

  POLYANET_URL = 'https://challenge.crossmint.com/api/polyanets'
  SOLOON_URL = 'https://challenge.crossmint.com/api/soloons'
  COMETH_URL = 'https://challenge.crossmint.com/api/comeths'

  GOAL_URL = "https://challenge.crossmint.com/api/map/#{CANDIDATE_ID}/goal"
  GOAL_FILENAME = 'goal.json'
end
