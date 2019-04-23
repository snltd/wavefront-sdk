#
# Stuff needed by multiple tests
#

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
require 'minitest/autorun'
require 'spy/integration'
require 'webmock/minitest'

# rubocop:disable Style/MutableConstant
CREDS = { endpoint: 'test.example.com',
          token:    '0123456789-ABCDEF' }
# rubocop:enable Style/MutableConstant

POST_HEADERS = {
  'Content-Type': 'text/plain', Accept: 'application/json'
}.freeze

JSON_POST_HEADERS = {
  'Content-Type': 'application/json', Accept: 'application/json'
}.freeze

DUMMY_RESPONSE = '{"status":{"result":"OK","message":"","code":200},' \
                 '"response":{"items":[{"name":"test data"}],"offset":0,' \
                 '"limit":100,"totalItems":3,"moreItems":false}}'.freeze

RESOURCE_DIR = (Pathname.new(__FILE__).dirname +
                'wavefront-sdk' + 'resources').freeze

# Common testing code
class WavefrontTestBase < MiniTest::Test
  attr_reader :wf, :wf_noop, :headers

  def initialize(args)
    require_relative "../lib/wavefront-sdk/#{class_basename.downcase}"
    super(args)
  end

  def class_basename
    self.class.name.match(/Wavefront(\w+)Test/)[1]
  end

  def api_base
    class_basename.downcase
  end

  def setup
    klass = Object.const_get('Wavefront').const_get(class_basename)
    @wf = klass.new(CREDS)
    @uri_base = uri_base
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def uri_base
    "https://#{CREDS[:endpoint]}/api/v2/" + api_base
  end

  def target_uri(path)
    return "https://#{CREDS[:endpoint]}#{path}" if path.start_with?('/')

    [uri_base, path].join(path.start_with?('?') ? '' : '/')
  end

  # A shorthand method for very common tests.
  #
  # @param method [String] the method you wish to test
  # @args [String, Integer, Array] arguments with which to call method
  # @path [String] extra API path components (beyond /api/v2/class)
  # @call [Symbol] the type of API call (:get, :put etc.)
  # @more_headers [Hash] any additional headers which should be
  #   sent. You will normally need to add these for :put and :post
  #   requests.
  # @body [String] a JSON object you expect to be sent as part of
  #   the request
  #
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/ParameterLists
  def should_work(method, args, path, call = :get, more_headers = {},
                  body = nil, id = nil)
    path = Array(path)
    uri = target_uri(path.first).sub(%r{/$}, '')

    headers = { 'Accept':          /.*/,
                'Accept-Encoding': /.*/,
                'Authorization':  'Bearer 0123456789-ABCDEF',
                'User-Agent':     "wavefront-sdk #{WF_SDK_VERSION}" }
              .merge(more_headers)

    if body
      stub_request(call, uri).with(body: body, headers: headers)
                             .to_return(body: DUMMY_RESPONSE, status: 200)
    else
      stub_request(call, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    end

    if args.is_a?(Hash)
      if id
        wf.send(method, id, args)
      else
        wf.send(method, args)
      end
    elsif id
      wf.send(method, id, *args)
    else
      wf.send(method, *args)
    end

    assert_requested(call, uri, headers: headers)
    WebMock.reset!
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/ParameterLists

  def standard_exception
    Object.const_get('Wavefront::Exception')
          .const_get("Invalid#{class_basename}Id")
  end

  def should_be_invalid(method, args = '!!invalid_val!!')
    assert_raises(standard_exception) { wf.send(method, *args) }
  end

  # Generic tag method testing.
  #
  def tag_tester(id)
    # Can we get tags? : tests #tags
    #
    should_work('tags', id, "#{id}/tag")
    should_be_invalid('tags')

    # Can we set tags? tests #tag_set
    #
    should_work('tag_set', [id, 'tag'],
                ["#{id}/tag", ['tag'].to_json], :post, JSON_POST_HEADERS)
    should_work('tag_set', [id, %w[tag1 tag2]],
                ["#{id}/tag", %w[tag1 tag2].to_json], :post,
                JSON_POST_HEADERS)
    should_fail_tags('tag_set', id)

    # Can we add tags? : tests #tag_add
    #
    should_work('tag_add', [id, 'tagval'],
                ["#{id}/tag/tagval", nil], :put, JSON_POST_HEADERS)
    should_fail_tags('tag_add', id)

    # Can we delete tags? : tests #tag_delete
    #
    should_work('tag_delete', [id, 'tagval'], "#{id}/tag/tagval", :delete)
    should_fail_tags('tag_delete', id)
  end

  def should_fail_tags(method, id)
    assert_raises(standard_exception) do
      wf.send(method, '!!invalid!!', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, id, '<!!!>')
    end
  end
end

# Extensions to stdlib
#
class Hash
  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end

# A mock socket
#
class Mocket
  def puts(socket); end

  def close; end

  def ok?
    true
  end
end

# A mock socket which says things went wrong.
#
class BadMocket < Mocket
  def ok?
    false
  end
end
