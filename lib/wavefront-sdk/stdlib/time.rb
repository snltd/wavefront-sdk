# frozen_string_literal: true

# Extensions to stdlib time module
#
class Time
  # @return [Integer] time in epoch milliseconds
  #
  def to_ms
    (to_f * 1000).round.to_i
  end

  # The real hi-res time. See
  # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
  #
  def self.right_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
