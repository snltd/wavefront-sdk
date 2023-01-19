# frozen_string_literal: true

# rubocop:disable Style/MutableConstant
CREDS = { endpoint: 'test.example.com',
          token: '0123456789-ABCDEF' }
# rubocop:enable Style/MutableConstant

W_CREDS = { proxy: 'wavefront', port: 2878 }.freeze

POST_HEADERS = {
  'Content-Type': 'text/plain', Accept: 'application/json'
}.freeze

JSON_POST_HEADERS = {
  'Content-Type': 'application/json', Accept: 'application/json'
}.freeze

DUMMY_RESPONSE = '{"status":{"result":"OK","message":"","code":200},' \
                 '"response":{"items":[{"name":"test data"}],"offset":0,' \
                 '"limit":100,"totalItems":3,"moreItems":false}}'

RESOURCE_DIR = Pathname.new(__FILE__).dirname.join('wavefront-sdk',
                                                   'resources').freeze

U_ACL_1 = 'someone@example.com'
U_ACL_2 = 'other@elsewhere.com'
GRP_ACL = 'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672'

DEFAULT_HEADERS = { Accept: /.*/,
                    'Accept-Encoding': /.*/,
                    Authorization: 'Bearer 0123456789-ABCDEF',
                    'User-Agent': /wavefront-sdk \d+\.\d+\.\d+/ }.freeze
