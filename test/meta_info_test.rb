require "test_helper"
require "time"

class RbLatex::MetaInfoTest < Test::Unit::TestCase

  def setup
    @meta_info = RbLatex::MetaInfo.new
  end

  def test_title
    @meta_info.title = "test title"
    assert_equal "test title", @meta_info.title
  end

  def test_creator
    @meta_info.creator = {aut: ["foo-san"]}
    assert_equal ["foo-san"], @meta_info.creator[:aut]
  end

  def test_date
    time = Time.parse("2018-05-01")
    @meta_info.pubdate = time
    assert_equal "2018年5月1日", @meta_info.pubdate_to_s
  end

  def test_add_creator
    assert_equal "", @meta_info.author
    @meta_info.add_creator("foo", "aut")
    @meta_info.add_creator("bar", "aut")
    assert_equal "foo, bar", @meta_info.author
  end

end
