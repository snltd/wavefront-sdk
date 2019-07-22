# A mock socket
#
class Mocket
  def puts(socket); end

  def close; end

  def ok?
    true
  end

  def response
    { sent: 1, rejected: 0, unsent: 0 }
  end

  def status
    { result: 'OK', message: nil, code: nil }
  end
end
