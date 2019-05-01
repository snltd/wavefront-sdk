#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/api_mixins/user'
require_relative '../../../lib/wavefront-sdk/validators'
require_relative '../../../lib/wavefront-sdk/core/exception'

# Test user mixins
#
class WavefrontUserMixinsTest < MiniTest::Test
  include Wavefront::Mixin::User
  include Wavefront::Validators

  def test_validate_user_list
    assert validate_user_list(%w[u1@d1.net u2@d2.org u3@d3.com])

    assert_raises(Wavefront::Exception::InvalidUserId) do
      validate_user_list(['', 'u1d1.net', 'u2@d2.org', 'u3@d3.com'])
    end

    assert_raises(Wavefront::Exception::InvalidUserId) do
      validate_user_list(['u1@d1.net', '', 'bbrg', 'u3@d3.com'])
    end

    assert_raises(ArgumentError) { validate_user_list('u1@d1.net') }
  end

  def validate_usergroup_list
    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      validate_user_list(%w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
                            '',
                            2659191e-aad4-4302-a94e-9667e1517127])
    end

    assert_raises(ArgumentError) do
      validate_usergroup_list('f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672')
    end
  end
end
