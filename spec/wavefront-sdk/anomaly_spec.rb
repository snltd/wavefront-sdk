#!/usr/bin/env ruby

require_relative '../spec_helper'

ANOM_OPTS = { offset:  0,
              limit:   100,
              startMs: 1_544_891_884_000,
              endMs:   1_544_891_884_000 }.freeze

ANOM_QS = '?offset=0&limit=100&startMs=1544891884000&' \
          'endMs=1544891884000'.freeze

ANOM_DASH = 'test_dashboard'.freeze

# XXX I have no idea what these hashes really look like. The API doc
# says they're a string though. Whether it means the data structure
# or and MD5-style hash, I don't know.
#
ANOM_PHASH = 'a=1,b=2'.freeze
ANOM_CHASH = 'c=3,d=4'.freeze

# Unit tests for anomaly class
#
class WavefrontAnomalyTest < WavefrontTestBase
  def test_defaults
    assert_equal({ offset: 10, limit: 200, startMs: 1_544_891_884_000,
                   endMs: 1_544_891_884_000 },
                 wf.defaults(offset: 10, limit: 200,
                             startMs: 1_544_891_884_000,
                             endMs: 1_544_891_884_000))

    assert_equal({ offset: 0, limit: 100, startMs: 1_544_891_884_000,
                   endMs: 1_544_891_884_000 },
                 wf.defaults(startMs: 1_544_891_884_000,
                             endMs: 1_544_891_884_000))

    x = wf.defaults

    assert_equal(x[:offset], 0)
    assert_equal(x[:limit], 100)
    assert_kind_of(Numeric, x[:startMs])
    assert_kind_of(Numeric, x[:endMs])
    assert(x[:startMs] > 1_544_891_884_000)
    assert(x[:endMs] > 1_544_891_884_000)
  end

  def test_list
    should_work(:list, ANOM_OPTS, ANOM_QS)
  end

  def test_dashboard
    should_work(:dashboard, [ANOM_DASH, nil, ANOM_OPTS],
                [ANOM_DASH, ANOM_QS].uri_concat)

    should_work(:dashboard, [ANOM_DASH, ANOM_PHASH, ANOM_OPTS],
                [ANOM_DASH, ANOM_PHASH, ANOM_QS].uri_concat)
  end

  def test_chart
    should_work(:chart, [ANOM_DASH, ANOM_CHASH, nil, ANOM_OPTS],
                [ANOM_DASH, 'chart', ANOM_CHASH, ANOM_QS].uri_concat)
    should_work(:chart, [ANOM_DASH, ANOM_CHASH, ANOM_PHASH, ANOM_OPTS],
                [ANOM_DASH, 'chart', ANOM_CHASH, ANOM_PHASH,
                 ANOM_QS].uri_concat)
  end
end
