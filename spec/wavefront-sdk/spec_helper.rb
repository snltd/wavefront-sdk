#
# Stuff needed by multiple tests
#
require 'minitest/autorun'
require 'webmock/minitest'

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

  def target_uri(path)
    [uri_base, path].join(path.start_with?('?') ? '' : '/')
  end

  def should_work(method, args, path, call = :get, more_headers = {})
    path = Array(path)
    uri = target_uri(path.first)

    headers = { 'Accept': '*/*; q=0.5, application/xml',
                'Accept-Encoding': 'gzip, deflate',
                'Authorization': 'Bearer 0123456789-ABCDEF',
                'User-Agent': 'Ruby'}.merge(more_headers)

    stub_request(call, uri).to_return(body: {}.to_json, status: 200)
    wf.send(method, *args)
    assert_requested(call, uri, headers: headers)
    WebMock.reset!
  end

  def should_be_invalid(method, args = '!!invalid_val!!')
    assert_raises(Object.const_get('Wavefront::Exception').const_get(
      "Invalid#{class_basename}")) do
      wf.send(method, *args)
    end
  end
end
