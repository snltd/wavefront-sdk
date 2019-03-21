#!/usr/bin/env ruby

require_relative '../spec_helper'

DASHBOARD = 'test_dashboard'.freeze
DASHBOARD_BODY = {
  name: 'SDK Dashboard test',
  id: 'sdk-test',
  description: 'dummy test dashboard',
  sections: [
    name: 'Section 1',
    rows: [
      { charts: [
        name: 'S1 Chart1',
        description: 'chart',
        sources: [
          { name: 'S1 C1 Source 1',
            query: 'ts("some.series")' }
        ]
      ] }
    ]
  ]
}.freeze

U_ACL_1 = { name: 'someone@example.com', id: 'someone@example.com' }.freeze
U_ACL_2 = { name: 'other@elsewhere.com', id: 'other@elsewhere.com' }.freeze
GRP_ACL = { name: 'example group',
            id:   'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672' }.freeze

# Unit tests for dashboard class
#
class WavefrontDashboardTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_create
    should_work(:create, DASHBOARD_BODY, '', :post,
                JSON_POST_HEADERS, DASHBOARD_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe
    should_work(:describe, DASHBOARD, DASHBOARD)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_describe_v
    should_work(:describe, [DASHBOARD, 4], "#{DASHBOARD}/history/4")
  end

  def test_delete
    should_work(:delete, DASHBOARD, DASHBOARD, :delete)
    should_be_invalid(:delete)
  end

  def test_update
    should_work(:update, [DASHBOARD, DASHBOARD_BODY, false],
                DASHBOARD, :put, JSON_POST_HEADERS,
                DASHBOARD_BODY.to_json)
    should_be_invalid(:update, ['!invalid dash!', DASHBOARD_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_favorite
    should_work(:favorite, DASHBOARD, ["#{DASHBOARD}/favorite",
                                       nil], :post, POST_HEADERS)
    should_work(:favourite, DASHBOARD, ["#{DASHBOARD}/favorite",
                                        nil], :post, POST_HEADERS)
    should_be_invalid(:favorite)
  end

  def test_history
    should_work(:history, DASHBOARD, "#{DASHBOARD}/history")
    should_be_invalid(:history)
  end

  def test_tags
    tag_tester(DASHBOARD)
  end

  def test_undelete
    should_work(:undelete, DASHBOARD, ["#{DASHBOARD}/undelete",
                                       nil], :post, POST_HEADERS)
    should_be_invalid(:undelete)
  end

  def test_unfavorite
    should_work(:unfavorite, DASHBOARD, ["#{DASHBOARD}/unfavorite",
                                         nil], :post, POST_HEADERS)
    should_work(:unfavourite, DASHBOARD, ["#{DASHBOARD}/unfavorite",
                                          nil], :post, POST_HEADERS)
    should_be_invalid(:unfavorite)
  end

  def test_acls
    should_work(:acls, [%w[dash1 dash2]], 'acl?id=dash1&id=dash2')
  end

  def test_acl_add
    should_work(:acl_add, [DASHBOARD, [U_ACL_1, U_ACL_2], [GRP_ACL]],
                'acl/add', :post, {}, acl_body(DASHBOARD,
                                               [U_ACL_1, U_ACL_2],
                                               [GRP_ACL]))

    should_work(:acl_add, [DASHBOARD, [U_ACL_1, U_ACL_2]],
                'acl/add', :post, {}, acl_body(DASHBOARD,
                                               [U_ACL_1, U_ACL_2]))
    assert_raises(ArgumentError) { wf.acl_add(DASHBOARD, U_ACL_1) }
    assert_raises(ArgumentError) do
      wf.acl_add(DASHBOARD, [U_ACL_1], GRP_ACL)
    end
  end

  def test_acl_remove
    should_work(:acl_delete, [DASHBOARD, [U_ACL_1, U_ACL_2], [GRP_ACL]],
                'acl/remove', :post, {}, acl_body(DASHBOARD,
                                                  [U_ACL_1, U_ACL_2],
                                                  [GRP_ACL]))

    should_work(:acl_delete, [DASHBOARD, [U_ACL_1, U_ACL_2]],
                'acl/remove', :post, {}, acl_body(DASHBOARD,
                                                  [U_ACL_1, U_ACL_2]))
    assert_raises(ArgumentError) { wf.acl_delete(DASHBOARD, U_ACL_1) }
  end

  def test_acl_set
    should_work(:acl_set, [DASHBOARD, [U_ACL_1, U_ACL_2], [GRP_ACL]],
                'acl/set', :put, {}, acl_body(DASHBOARD,
                                              [U_ACL_1, U_ACL_2],
                                              [GRP_ACL]))

    should_work(:acl_set, [DASHBOARD, [U_ACL_1, U_ACL_2]],
                'acl/set', :put, {}, acl_body(DASHBOARD,
                                              [U_ACL_1, U_ACL_2]))
    assert_raises(ArgumentError) { wf.acl_set(DASHBOARD, U_ACL_1) }
  end

  def acl_body(id, view = [], modify = [])
    [{ entityId: id, viewAcl: view, modifyAcl: modify }].to_json
  end
end
