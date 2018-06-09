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
    attr_accessor :debug
    attr_accessor :book_name
    attr_accessor :titlepage
    attr_accessor :colophons
    attr_accessor :colophon_template
    attr_reader :work_dir

    RbLatex::MetaInfo::ATTRS.each do |name|
      def_delegator :@meta_info, name
      name_eq = "#{name}=".to_sym
      def_delegator :@meta_info, name_eq
    end

    def_delegators :@meta_info, :lastmodified, :lastmodified=, :add_creator
    def_delegator :@meta_info, :pubdate, :date
    def_delegator :@meta_info, :pubdate=, :date=

    def initialize(root_dir)
      @root_dir = root_dir
      @root_fullpath = File.absolute_path(root_dir)
      @work_dir = ".rblatex_work"
      @item_list = RbLatex::ItemList.new
      @meta_info = RbLatex::MetaInfo.new
      @latex_command = "uplatex"
      @dvipdf_command = "dvipdfmx"
      @document_class = ["jlreq", "book,b5paper,openany"]
      @debug = nil
      @book_name = "book"
      @default_option = nil
      @colophon_template = "colophon.tex.erb"
      @colophons = nil
      @titlepage = nil
    end

    def add_item(filename, content)
      @item_list.add_item(filename, content)
    end

    def book_filename(ext = ".pdf")
      "#{@book_name}#{ext}"
    end

    def generate_pdf(filename, debug: nil)
      in_working_dir(debug) do |dir|
        copy_files(dir)
        Dir.chdir(dir) do
          generate_src(dir)
          compile_latex(dir)
        end
        FileUtils.cp(File.join(dir, book_filename), filename)
      end
    end

    def copy_files(dir)
      Dir.entries(@root_dir).each do |path|
        next if path == "." or path == ".." or path == @work_dir
        FileUtils.cp_r(File.join(@root_dir, path), dir, dereference_root: true)
      end
    end

    def generate_src(dir)
      @item_list.generate(dir)
      @dclass, @dclass_option = @document_class
      if @meta_info.page_progression_direction == "rtl" && !@dclass_option.split(",").include?("tate")
        @dclass_option += ",tate"
      end
      if @latex_command =~ /lualatex/
        @default_option = "luatex"
      end
      book_tex = apply_template("book.tex.erb")
      File.write(File.join(dir, book_filename(".tex")), book_tex)
      rblatexdefault_sty = apply_template("rblatexdefault.sty")
      File.write(File.join(dir, "rblatexdefault.sty"), rblatexdefault_sty)
      if @colophons
        colophon_tex = apply_template(@colophon_template, template_dir: @colophon_dir)
        File.write(File.join(dir, "colophon.tex"), colophon_tex)
      end
    end

    def compile_latex(dir)
      texfile = book_filename(".tex")
      cmd = "#{@latex_command} #{texfile}"
      3.times do |i|
        out, status = Open3.capture2e(cmd)
        if !status.success?
          @error_log = out
          if @debug
            print STDERR, @error_log, "\n"
          end
          raise RbLatex::Error, "fail to exec latex (#{i}): #{cmd}"
        end
      end
      dvifile = book_filename(".dvi")
      if File.exist?(dvifile)
        exec_dvipdf(dvifile)
      end
    end

    def exec_dvipdf(dvifile)
      cmd = "#{@dvipdf_command} #{dvifile}"
      out, status = Open3.capture2e(cmd)
      if !status.success?
        @error_log = out
        raise RbLatex::Error, "fail to exec dvipdf: #{cmd}"
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

    def apply_template(template_file, template_dir: nil)
      template_dir ||= RbLatex::TEMPLATES_DIR
      template = File.read(File.join(template_dir, template_file))
      return ERB.new(template, nil, '-').result(binding)
    end

  end
end
