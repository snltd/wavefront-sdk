# frozen_string_literal: true

# A mock socket which says things went wrong.
#
class BadMocket < Mocket
  def ok?
    false
  end

  def status
    { result: 'ERROR', message: nil, code: nil }
  end

  def response
    { sent: 0, rejected: 1, unsent: 0 }
  end
end
