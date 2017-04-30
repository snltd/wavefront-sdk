#
# Stuff needed by multiple tests
#
require 'minitest/autorun'
require 'webmock/minitest'

CREDS = {
  endpoint: 'test.example.com',
  token:    '0123456789-ABCDEF'
}.freeze

# Known-valid values for various objects
#
ALERT = '1481553823153'.freeze
AGENT = 'fd248f53-378e-4fbe-bbd3-efabace8d724'.freeze
CLOUD = '3b56f61d-1a79-46f6-905c-d75a0f613d10'.freeze
DASHBOARD = 'test_dashboard'.freeze
EVENT = '1481553823153:testev'.freeze
EXTERNAL_LINK = 'lq6rPlSg2CFMSrg6'.freeze
WINDOW = '1493324005091'.freeze

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
  #
  def should_work(method, args, path, call = :get, more_headers = {},
                 body = nil, id = nil)
    path = Array(path)
    uri = target_uri(path.first).sub(/\/$/, '')

    headers = { 'Accept': '*/*; q=0.5, application/xml',
                'Accept-Encoding': 'gzip, deflate',
                'Authorization': 'Bearer 0123456789-ABCDEF',
                'User-Agent': 'Ruby'}.merge(more_headers)

    if body
      headers['Content-Length'] = body.size.to_s
      stub_request(call, uri).with(body: body, headers:headers)
        .to_return(body: {}.to_json, status: 200)
    else
      stub_request(call, uri).to_return(body: {}.to_json, status: 200)
    end

    if args.is_a?(Hash)
      if id
        wf.send(method, id, args)
      else
        wf.send(method, args)
      end
    else
      if id
        wf.send(method, id, *args)
      else
        wf.send(method, *args)
      end
    end

    assert_requested(call, uri, headers: headers)
    WebMock.reset!
  end

  def should_be_invalid(method, args = '!!invalid_val!!')
    assert_raises(Object.const_get('Wavefront::Exception').const_get(
      "Invalid#{class_basename}")) do
      wf.send(method, *args)
    end
  end

  # Perform a whole bunch of tests on a post or put method.
  #
  def body_test(h)
    method = h[:method] || 'create'
    headers = JSON_POST_HEADERS
    rtype = h[:rtype] || :post
    id = h[:id] || nil
    path = h[:id] ? h[:id] : ''

    # Ensure the body block works as-is
    #
    should_work(method, h[:hash], path, rtype, headers,
                h[:hash].to_json, id)

    # One by one, remove all optional fields and make sure it still
    # works
    #
    h[:optional].each do |k|
      tmp = h[:hash].dup
      tmp.delete(k)
      should_work(method, tmp, path, rtype, headers, tmp.to_json, id)
    end

    # Remove all optional fields and make sure it still works
    #
    tmp = h[:hash].reject { |k, _v| h[:optional].include?(k) }
    should_work(method, tmp, path, rtype, headers, tmp.to_json, id)

    # Deliberately break fields which must be validated, and ensure
    # we see the right exceptions.
    #
    h[:invalid].each do |exception, keys|
      keys.each do |k|
        tmp = h[:hash].dup
        tmp[k] = '!! invalid field !!'

        if id
          assert_raises(exception) { wf.send(method, id, tmp) }
        else
          assert_raises(exception) { wf.send(method, tmp) }
        end
      end
    end

    # Make sure things break properly when we don't pass required
    # keys
    #
    h[:required].each do |k|
      tmp = h[:hash].dup
      tmp.delete(k)
      assert_raises("missing key: #{k}") { wf.send(method, tmp) }
    end

    assert_raises(ArgumentError) { wf.send(method) }
    assert_raises(ArgumentError) { wf.send(method, 'rubbish') }
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
    should_work('tag_set', [id, %w(tag1 tag2)],
                ["#{id}/tag", %w(tag1 tag2).to_json], :post,
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
    assert_raises(Wavefront::Exception::InvalidEvent) do
      wf.send(method, '!!invalid!!', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, id, '<!!!>')
    end
  end
end

class Hash

  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end
