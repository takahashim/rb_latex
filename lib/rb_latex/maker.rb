require 'forwardable'
require 'fileutils'
require "open3"

module RbLatex
  class Maker
    extend Forwardable

    def_delegator :@meta_info, :title
    def_delegator :@meta_info, :title=
    def_delegator :@meta_info, :creator
    def_delegator :@meta_info, :creator=
    def_delegator :@meta_info, :date
    def_delegator :@meta_info, :date=
    def_delegator :@meta_info, :lastmodified
    def_delegator :@meta_info, :lastmodified=
    def_delegator :@meta_info, :page_progression_direction
    def_delegator :@meta_info, :page_progression_direction=
    def_delegator :@meta_info, :add_creator

    attr_reader :workdir

    def initialize(srcdir)
      @srcdir = srcdir
      @config = default_config
      @workdir = ".rblatex_work"
      @item_list = RbLatex::ItemList.new
      @meta_info = RbLatex::ItemList.new
    end

    def default_config
      {}
    end

    def add_item(filename, content)
      @item_list.add_item(filename, content)
    end

    def generate_pdf(filename, debug: nil)
      change_working_dir(debug) do |dir|
        copy_files(dir)
        generate_src(dir)
        exec_latex(dir)
        exec_dvipdfmx(dir)
      end
    end

    def copy_files(dir)
      Dir.entries(@src).each do |path|
        next if path == "." or path == ".."
        FileUtils.cp_r(path, dir, :dereference_root)
      end
    end

    def generate_src(dir)
      @item_list.generate(dir)
    end

    def exec_latex(dir)
      cmd = "#{@latex_cmd} book.tex"
      3.times do |i|
        out, status = Open3.capture2e(cmd)
        if !status.success?
          @error_log = out
          raise RbLatex::Error, "fail to exec latex #{i}: #{cmd}"
        end
      end
    end

    def exec_dvipdfmx(dir)
      cmd = "#{@dvipdfmx_cmd} book.dvi"
      out, status = Open3.capture2e(cmd)
      if !status.success?
        @error_log = out
        raise RbLatex::Error, "fail to exec latex #{i}: #{cmd}"
      end
      FileUtils.cp("book.pdf", File.join(@src, "book.pdf"))
    end

    def workdir=(dir)
      if dir =~ /\A[A-Za-z0-9_\.-]+\z/
        @workdir = dir
      else
        raise RbLatex::Error, "workdir should use characters 'A-Za-z0-9_.-' only."
      end
    end

    def change_working_dir(debug)
      workdir = prepare_working_dir(debug)
      begin
        Dir.chdir(workdir) do |dir|
          yield dir
        end
      ensure
        if !debug
          FileUtils.remove_entry_secure(dir)
        end
      end
    end

    def prepare_working_dir(debug)
      if !debug
        Dir.mktmpdir('rblatex')
      else
        FileUtils.remove_entry_secure(@workdir)
        Dir.mkdir(@workdir)
        @workdir
      end
    end
  end
end
