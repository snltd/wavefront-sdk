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
CLOUD = '3b56f61d-1a79-46f6-905c-d75a0f613d10'.freeze
DASHBOARD = 'test_dashboard'.freeze

POST_HEADERS = {
  :'Content-Type' => 'text/plain', :Accept => 'application/json'
}.freeze

JSON_POST_HEADERS = {
  :'Content-Type' => 'application/json', :Accept => 'application/json'
}.freeze

class WavefrontTestBase < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def initialize(args)
    require_relative "../../lib/wavefront-sdk/#{class_basename.downcase}"
    super(args)
  end

  def class_basename
    self.class.name.match(/Wavefront(\w+)Test/)[1]
  end

  def setup
    klass = Object.const_get('Wavefront').const_get(class_basename)
    @wf = klass.new(CREDS)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/" +
                class_basename.downcase
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def should_work(method, args, path, api_method = :get,
                  more_headers = {})

    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, api_method)
    json = Spy.on(JSON, :parse)

    wf.send(method, *args)

    h = headers.merge(more_headers)
    rc_args = Array(path).<< h
    join_char = rc_args[0].start_with?('?') ? '' : '/'

    rc_args[0] = [uri_base, rc_args[0]].join(join_char)

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

  def should_be_invalid(method, args = '!!invalid_val!!')
    assert_raises(Object.const_get('Wavefront::Exception').const_get(
      "Invalid#{class_basename}")) do
      wf.send(method, *args)
    end
  end
end
