# Extensions to stdlib
#
class Hash
  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end
