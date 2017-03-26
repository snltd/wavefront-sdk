#
# Stuff needed by multiple tests
#
require 'rest-client'
require 'minitest/autorun'
require 'spy/integration'

CREDS = {
  endpoint: 'test.example.com',
  token:    '0123456789-ABCDEF'
}.freeze

ALERT = '1481553823153'.freeze
AGENT = 'fd248f53-378e-4fbe-bbd3-efabace8d724'.freeze
