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
    @meta_info.date = time
    assert_equal "2018年5月1日", @meta_info.date_to_s
  end

  def test_add_creator
    @meta_info.add_creator("foo", "aut")
  end

end
