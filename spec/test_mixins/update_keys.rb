# frozen_string_literal: true

module WavefrontTest
  #
  # include this into any class which has update keys
  #
  module UpdateKeys
    def test_update_keys
      assert_instance_of Array, wf.update_keys
      assert(wf.update_keys.all? { |k| k.is_a?(Symbol) })
    end
  end
end
