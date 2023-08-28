#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/spy'

# Unit tests for Spy class
#
class WavefrontSpyTest < Minitest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Spy.new(CREDS)
  end

  def test_points
    capture_io do
      assert_gets('/api/spy/points?sampling=0.01') { wf.points }
      assert_gets('/api/spy/points?sampling=0.05') { wf.points(0.05) }

      assert_gets('/api/spy/points?sampling=0.05&metric=my_prefix') do
        wf.points(0.05, prefix: 'my_prefix')
      end

      assert_gets('/api/spy/points?sampling=0.05&metric=my_prefix&host=h1') do
        wf.points(0.05, prefix: 'my_prefix', host: 'h1')
      end

      assert_gets('/api/spy/points?sampling=0.02&metric=my_prefix&' \
                  'pointTagKey=mytag') do
        wf.points(0.02, prefix: 'my_prefix', tag_key: 'mytag')
      end

      assert_gets('/api/spy/points?sampling=0.02&metric=my_prefix&' \
                  'pointTagKey=tag1&pointTagKey=tag2') do
        wf.points(0.02, prefix: 'my_prefix', tag_key: %w[tag1 tag2])
      end
    end
  end

  def test_deltas
    capture_io do
      assert_gets('/api/spy/deltas?sampling=0.01') { wf.deltas }
      assert_gets('/api/spy/deltas?sampling=0.05') { wf.deltas(0.05) }

      assert_gets('/api/spy/deltas?sampling=0.05&counter=my_prefix') do
        wf.deltas(0.05, prefix: 'my_prefix')
      end

      assert_gets(
        '/api/spy/deltas?sampling=0.05&counter=my_prefix&host=h1'
      ) do
        wf.deltas(0.05, prefix: 'my_prefix', host: 'h1')
      end

      assert_gets('/api/spy/deltas?sampling=0.02&counter=my_prefix&' \
                  'counterTagKey=the_tag') do
        wf.deltas(0.02, prefix: 'my_prefix', tag_key: 'the_tag')
      end

      assert_gets('/api/spy/deltas?sampling=0.02&counter=my_prefix&' \
                  'counterTagKey=tag1&counterTagKey=tag2') do
        wf.deltas(0.02, prefix: 'my_prefix', tag_key: %w[tag1 tag2])
      end
    end
  end

  def test_histograms
    capture_io do
      assert_gets('/api/spy/histograms?sampling=0.01') { wf.histograms }
      assert_gets('/api/spy/histograms?sampling=0.05') { wf.histograms(0.05) }

      assert_gets('/api/spy/histograms?sampling=0.05&histogram=my_prefix') do
        wf.histograms(0.05, prefix: 'my_prefix')
      end

      assert_gets(
        '/api/spy/histograms?sampling=0.05&histogram=my_prefix&host=h1'
      ) do
        wf.histograms(0.05, prefix: 'my_prefix', host: 'h1')
      end

      assert_gets('/api/spy/histograms?sampling=0.02&histogram=my_prefix&' \
                  'histogramTagKey=the_tag') do
        wf.histograms(0.02, prefix: 'my_prefix', tag_key: 'the_tag')
      end

      assert_gets('/api/spy/histograms?sampling=0.02&histogram=my_prefix&' \
                  'histogramTagKey=tag1&histogramTagKey=tag2') do
        wf.histograms(0.02, prefix: 'my_prefix', tag_key: %w[tag1 tag2])
      end
    end
  end

  def test_spans
    capture_io do
      assert_gets('/api/spy/spans?sampling=0.01') { wf.spans }
      assert_gets('/api/spy/spans?sampling=0.05') { wf.spans(0.05) }

      assert_gets('/api/spy/spans?sampling=0.05&name=my_prefix') do
        wf.spans(0.05, prefix: 'my_prefix')
      end

      assert_gets(
        '/api/spy/spans?sampling=0.05&name=my_prefix&host=h1'
      ) do
        wf.spans(0.05, prefix: 'my_prefix', host: 'h1')
      end

      assert_gets('/api/spy/spans?sampling=0.02&name=my_prefix&' \
                  'spanTagKey=the_tag') do
        wf.spans(0.02, prefix: 'my_prefix', tag_key: 'the_tag')
      end

      assert_gets('/api/spy/spans?sampling=0.02&name=my_prefix&' \
                  'spanTagKey=tag1&spanTagKey=tag2') do
        wf.spans(0.02, prefix: 'my_prefix', tag_key: %w[tag1 tag2])
      end
    end
  end

  def test_ids
    capture_io do
      assert_gets('/api/spy/ids?sampling=0.01') { wf.ids }
      assert_gets('/api/spy/ids?sampling=0.05') { wf.ids(0.05) }

      assert_gets('/api/spy/ids?sampling=0.05&type=METRIC') do
        wf.ids(0.05, type: 'METRIC')
      end

      assert_gets('/api/spy/ids?sampling=0.05&type=SPAN&name=my_prefix') do
        wf.ids(0.05, type: 'SPAN', prefix: 'my_prefix')
      end
    end
  end

  def dummy_response
    DUMMY_RESPONSE
  end
end
