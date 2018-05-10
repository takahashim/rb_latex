require "test_helper"
require "time"
require "tmpdir"

class RbLatex::MakerTest < Test::Unit::TestCase

  def setup
    @maker = RbLatex::Maker.new(Dir.pwd)
  end

  def test_title
    @maker.title = "test title"
    assert_equal "test title", @maker.title
  end

  def test_copy_files
    Dir.mktmpdir do |dir|
      @maker2 = RbLatex::Maker.new(dir)
      Dir.chdir(dir) do
        @maker2.add_item("file.txt", "hello\nworld\n")
        @maker2.add_item("file2.txt", "hello\nworld 2\n")
        @maker2.generate_src(dir)
        Dir.mktmpdir do |dir2|
          @maker2.copy_files(dir2)
          assert_true File.exist?(File.join(dir2, "file.txt"))
          assert_true File.exist?(File.join(dir2, "book.tex"))
          assert_true File.exist?(File.join(dir2, "rblatexdefault.sty"))
        end
      end
    end
  end

  def test_work_dir
    Dir.mktmpdir do |dir|
      @maker2 = RbLatex::Maker.new(dir)
      Dir.chdir(dir) do
        @maker2.work_dir = "hoge.dummy"
        @maker2.add_item("file.txt", "hello\nworld\n")
        @maker2.add_item("file2.txt", "hello\nworld 2\n")
        @maker2.in_working_dir(true) do |wdir|
          assert_equal "hoge.dummy", File.split(wdir)[1]
          @maker2.generate_src(dir)
          Dir.mktmpdir do |dir2|
            @maker2.copy_files(dir2)
            assert_true File.exist?(File.join(dir2, "file.txt"))
            assert_true File.exist?(File.join(dir2, "book.tex"))
            assert_true File.exist?(File.join(dir2, "rblatexdefault.sty"))
          end
        end
      end
    end
  end

end
