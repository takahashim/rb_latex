module RbLatex
  module Utils

    ESCAPE_CHARS = {
      "{" => "\\{",
      "}" => "\\}",
      "\\" => "\\textbackslash{}",
      "#" => "\\#",
      "$" => "\\$",
      "%" => "\\%",
      "&" => "\\&",
      "^" => "\\textasciicircum{}",
      "_" => "\\_",
      "~" => "\\textasciitilde{}",
    }

    def escape_latex(str)
      str.each_char.map do |char|
        ESCAPE_CHARS[char] || char
      end.join("")
    end
    module_function :escape_latex
  end
end
