require 'forwardable'
require 'fileutils'
require "open3"
require "rb_latex/meta_info"

module RbLatex
  class Maker
    extend Forwardable

    attr_accessor :document_class
    attr_accessor :latex_command
    attr_accessor :dvipdf_command

    RbLatex::MetaInfo::ATTRS.each do |name|
      def_delegator :@meta_info, name
      name_eq = "#{name}=".to_sym
      def_delegator :@meta_info, name_eq
    end

    def_delegator :@meta_info, :date
    def_delegator :@meta_info, :date=
    def_delegator :@meta_info, :lastmodified
    def_delegator :@meta_info, :lastmodified=
    def_delegator :@meta_info, :add_creator

    attr_reader :work_dir

    def initialize(root_dir)
      @root_dir = root_dir
      @root_fullpath = File.absolute_path(root_dir)
      @config = default_config
      @work_dir = ".rblatex_work"
      @item_list = RbLatex::ItemList.new
      @meta_info = RbLatex::MetaInfo.new
      @latex_command = "uplatex"
      @dvipdf_command = "dvipdfmx"
      @document_class = ["jlreq", "book,b5paper,openany"]
    end

    def default_config
      {}
    end

    def add_item(filename, content)
      @item_list.add_item(filename, content)
    end

    def generate_pdf(filename, debug: nil)
      in_working_dir(debug) do |dir|
        copy_files(dir)
        Dir.chdir(dir) do
          generate_src(dir)
          exec_latex(dir)
          exec_dvipdf(dir)
        end
        FileUtils.cp(File.join(dir, "book.pdf"), filename)
      end
    end

    def copy_files(dir)
      Dir.entries(@root_dir).each do |path|
        next if path == "." or path == ".." or path =~ /\A\.rblatex/
        FileUtils.cp_r(File.join(@root_dir, path), dir, dereference_root: true)
      end
    end

    def generate_src(dir)
      @item_list.generate(dir)
      @dclass, @dclass_opt = @document_class
      if @meta_info.page_progression_direction == "rtl" && !@dclass_opt.split(",").include?("tate")
        @dclass_opt += ",tate"
      end
      book_tex = apply_template("book.tex.erb")
      File.write(File.join(dir, "book.tex"), book_tex)
    end

    def exec_latex(dir)
      cmd = "#{@latex_command} book.tex"
      3.times do |i|
        out, status = Open3.capture2e(cmd)
        if !status.success?
          @error_log = out
          raise RbLatex::Error, "fail to exec latex #{i}: #{cmd}"
        end
      end
    end

    def exec_dvipdf(dir)
      cmd = "#{@dvipdf_command} book.dvi"
      out, status = Open3.capture2e(cmd)
      if !status.success?
        @error_log = out
        raise RbLatex::Error, "fail to exec latex #{i}: #{cmd}"
      end
    end

    def work_dir=(dir)
      if dir =~ /\A[A-Za-z0-9_\.-]+\z/
        @work_dir = dir
      else
        raise RbLatex::Error, "work_dir should use characters 'A-Za-z0-9_.-' only."
      end
    end

    def in_working_dir(debug)
      work_dir = prepare_working_dir(debug)
      begin
        yield work_dir
      ensure
        if !debug
          FileUtils.remove_entry_secure(work_dir)
        end
      end
    end

    def prepare_working_dir(debug)
      if !debug
        Dir.mktmpdir('rblatex')
      else
        FileUtils.rm_rf(@work_dir)
        Dir.mkdir(@work_dir)
        File.absolute_path(@work_dir)
      end
    end

    def apply_template(template_file)
      template = File.read(File.join(RbLatex::TEMPLATES_DIR, template_file))
      return ERB.new(template).result(binding)
    end

  end
end
