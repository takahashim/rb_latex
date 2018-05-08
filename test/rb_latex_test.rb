require "test_helper"

class RbLatexTest < Test::Unit::TestCase
  def test_has_a_version_number
    refute_nil ::RbLatex::VERSION
  end

end
