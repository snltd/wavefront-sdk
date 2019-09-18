# frozen_string_literal: true

# Constants used in the write tests
#
TAGS    = { gt1: 'gv1', gt2: 'gv2' }.freeze

POINT   = { path: 'test.metric',
            value: 123_456,
            ts: 1_469_987_572,
            source: 'testhost',
            tags: { t1: 'v1', t2: 'v2' } }.freeze

POINT_L = 'test.metric 123456 1469987572 source=testhost t1="v1" ' \
          't2="v2"'

POINT_A = [POINT,
           POINT.dup.update(ts: 1_469_987_588, value: 54_321)].freeze

POINTS  = [POINT.dup, { path: 'test.other_metric',
                        value: 89,
                        ts: 1_469_987_572,
                        source: 'otherhost' }].freeze
