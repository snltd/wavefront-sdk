# frozen_string_literal: true

module WavefrontTest
  #
  # require and include this module to get ACL tests
  #
  module Acl
    def test_acls
      assert_gets("/api/v2/#{api_class}/acl?id=#{id}&id=#{id.reverse}") do
        wf.acls([id, id.reverse])
      end
    end

    def test_acl_add
      assert_posts("/api/v2/#{api_class}/acl/add",
                   acl_body(id, user_acls, group_acls)) do
        wf.acl_add(id, user_acls, group_acls)
      end

      assert_posts("/api/v2/#{api_class}/acl/add",
                   acl_body(id, user_acls)) do
        wf.acl_add(id, user_acls)
      end

      assert_raises(ArgumentError) { wf.acl_add(id, user_acls.first) }
      assert_raises(ArgumentError) do
        wf.acl_add(id, user_acls, group_acls.first)
      end
    end

    def test_acl_delete
      assert_posts("/api/v2/#{api_class}/acl/remove",
                   acl_body(id, user_acls, group_acls)) do
        wf.acl_delete(id, user_acls, group_acls)
      end

      assert_posts("/api/v2/#{api_class}/acl/remove",
                   acl_body(id, user_acls)) do
        wf.acl_delete(id, user_acls)
      end

      assert_raises(ArgumentError) { wf.acl_delete(id, U_ACL_1) }
    end

    def test_acl_set
      assert_puts("/api/v2/#{api_class}/acl/set",
                  acl_body(id, user_acls, group_acls)) do
        wf.acl_set(id, user_acls, group_acls)
      end

      assert_puts("/api/v2/#{api_class}/acl/set",
                  acl_body(id, user_acls)) do
        wf.acl_set(id, user_acls)
      end

      assert_raises(ArgumentError) { wf.acl_set(id, U_ACL_1) }
    end

    private

    # @return [Array[String]] list of user IDs for ACL testing
    #
    def user_acls
      %w[someone@example.com other@elsewhere.com]
    end

    # @return [Array[String]] list of group IDs for ACL testing
    #
    def group_acls
      %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672]
    end

    # @return [String] JSON representation of an ACL request
    #   payload
    #
    def acl_body(id, view = [], modify = [])
      [{ entityId: id, viewAcl: view, modifyAcl: modify }].to_json
    end
  end
end
