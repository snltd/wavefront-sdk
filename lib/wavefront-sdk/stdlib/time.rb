# frozen_string_literal: true

# Extensions to the stdlib Time class
#
class Time
  #
  # The real hi-res time. See
  # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
  #
  def self.right_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
