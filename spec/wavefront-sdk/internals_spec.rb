#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zlib'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/internals'

# Tests for internal methods
#
class TestInternals < Minitest::Test
  attr_reader :t

  def setup
    @t = Wavefront::Internals.new
  end

  def test_sdk_files
    result = t.sdk_files
    assert_instance_of(Array, result)
    assert(result.all?(&:file?))
    assert(result.all? { |f| f.extname == '.rb' })
  end

  def test_supported_api_paths
    result = t.supported_api_paths
    assert_instance_of(Array, result)
    assert paths_are_good(result)
  end

  def test_remote_api_paths
    result = t.remote_api_paths(spec_resource)

    assert paths_are_good(result)
  end

  def paths_are_good(result)
    verbs = %w[GET PUT POST PATCH DELETE]

    assert(result.all? do |verb, path|
      verbs.include?(verb) && (path == '/report' ||
                               path.match?(%r{^/api/(v2|spy)/}))
    end)

    assert_includes(result, ['GET', '/api/v2/usage/ingestionpolicy/{id}'])
    assert_includes(result, ['POST', '/api/v2/dashboard/acl/add'])
    assert_includes(result, ['PUT', '/api/v2/dashboard/{id}/tag/{tagValue}'])

    assert_includes(result, ['POST', '/api/v2/search/derivedmetric'])
    assert_includes(result, ['POST', '/api/v2/search/derivedmetric/deleted'])
    # assert_includes(result,
    #                 ['POST', '/api/v2/search/derivedmetric/deleted/facets'])
    # assert_includes(result,
    #                 ['POST', '/api/v2/search/derivedmetric/deleted/{facet}'])
    assert_includes(result, ['POST', '/api/v2/search/derivedmetric/facets'])
    assert_includes(result, ['POST', '/api/v2/search/derivedmetric/{facet}'])
    assert_includes(result, ['POST', '/api/v2/search/event'])
  end

  def spec_resource
    Zlib::GzipReader.new(File.open(RESOURCE_DIR.join('swagger.spec.gz'))).read
  end
end
