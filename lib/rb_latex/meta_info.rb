module RbLatex
  class MetaInfo

    ATTRS = %i(title creator page_progression_direction language publisher colophons colophon_keys)

    ATTRS.each do |name|
      attr_accessor name
    end

    attr_reader :pubdate, :lastmodified

    def initialize
      @creator = Hash.new
      @pubdate = nil
    end

    def pubdate=(time)
      if time.kind_of? String
        @pubdate = Time.parse(time)
      else
        @pubdate = time
      end
    end

    def pubdate_to_s
      date_format(@pubdate)
    end

    def lastmodified=(time)
      if time.kind_of? String
        @lastmodified = Time.parse(time)
      else
        @lastmodified = time
      end
    end

    def lastmodified_to_s
      date_format(@lastmodified)
    end

    def all
##      @info
    end

    def colophons
      {'author' => author,
       'publisher' => publisher}
    end

    def to_latex
      "\\newcommand{\\rblatexTitle}{#{escape_latex(title)}}\n"+
      "\\newcommand{\\rblatexAuthor}{#{escape_latex(author)}}\n"+
      "\\newcommand{\\rblatexPubdate}{#{escape_latex(date_to_s)}}\n"+
      "\\newcommand{\\rblatexPublisher}{#{escape_latex(publisher)}}\n"+
      "\\newcommand{\\rblatexPageDirection}{#{escape_latex(page_progression_direction)}}\n"
    end

    def date_format(time)
      time.strftime("%Y年%-m月%-d日")
    end

    def add_creator(name, role)
      if !@creator[role]
        !@creator[role] = Array.new
      end
      @creator[role] << name
    end

    def author(sep = ", ")
      aut = @creator["aut"]
      if aut
        aut.join(sep)
      else
        ""
      end
    end
  end
end
