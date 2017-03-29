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

POST_HEADERS = {
    'Content-Type': 'text/plain', Accept: 'application/json'
}.freeze

JSON_POST_HEADERS = {
    'Content-Type': 'application/json', Accept: 'application/json'
}.freeze

def should_work(method, args, path, api_method = :get,
                more_headers = {}, debug = false)

  msg = Spy.on(wf, :msg)
  rc = Spy.on(RestClient, api_method)
  json = Spy.on(JSON, :parse)

  wf.send(method, *args)

  h = headers.merge(more_headers)
  rc_args = Array(path).<< h
  join_char = rc_args[0].start_with?('?') ? '' : '/'

  rc_args[0] = [uri_base, rc_args[0]].join(join_char)

  if debug
    puts "api_method: #{api_method}"
    puts "headers:    #{h}"
    puts "args:       #{rc_args}"
  end

  assert rc.has_been_called_with?(*rc_args)
  assert json.has_been_called?
  refute msg.has_been_called?

  # unhook the Spy objects so we can call multiple tests from the same
  # test_ method
  #
  msg.unhook
  json.unhook
  rc.unhook
end
