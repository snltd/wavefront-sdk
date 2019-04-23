#
# Extensions to stdlib SizedQueue class
#
class SizedQueue
  def to_a
    size.times.with_object([]) { |_, a| a.<< shift }
  end
end
