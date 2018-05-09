require "test_helper"

class RbLatex::UtilsTest < Test::Unit::TestCase
  def test_escape
    assert_equal "abc", RbLatex::Utils.escape_latex("abc")
    assert_equal "a\\textbackslash{}b\\_c", RbLatex::Utils.escape_latex("a\\b_c")
    assert_equal "\\#ab\\{\\}c\\$", RbLatex::Utils.escape_latex("#ab{}c$")
  end

  class DummyFoo
    include RbLatex::Utils
    def foo(str)
      str + ":" + escape_latex(str)
    end
  end

  def test_escape_in_class
    assert_equal "abc:abc", DummyFoo.new.foo("abc")
    assert_equal "a\\b_c:a\\textbackslash{}b\\_c", DummyFoo.new.foo("a\\b_c")
    assert_equal "#ab{}c$:\\#ab\\{\\}c\\$", DummyFoo.new.foo("#ab{}c$")
  end
end
