# frozen_string_literal: true

# Extensions to stdlib time module
#
class Time
  # @return [Integer] time in epoch milliseconds
  #
  def to_ms
    (to_f * 1000).round.to_i
  end
end
