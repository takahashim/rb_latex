require "test_helper"

class RbLatex::ColophonTest < Test::Unit::TestCase

  def setup
    @maker = RbLatex::Maker.new(Dir.pwd)
  end

  def test_colophon
    @maker.colophons = {"著　者" => "ジョン・テスト",
                        "訳　者" => ["田中一郎","田中二郎"],
                        "発行日" => "2018年5月1日",
                        "発行所" => "テスト出版",
                        "印刷所" => "テスト印刷"}
    colophon_tex = @maker.apply_template("colophon.tex.erb")
    expected = <<-EOB
\\newpage
\\thispagestyle{empty}
\\vspace*{\\fill}
{\\noindent\\Large \\rblatexTitle } \\\\
\\rblatexColophonBefore \\\\
\\rule[2pt]{\\textwidth}{1pt} \\\\
\\begin{tabular}{ll}
著　者 & ジョン・テスト \\\\
訳　者 & 田中一郎 \\\\
 & 田中二郎 \\\\
発行日 & 2018年5月1日 \\\\
発行所 & テスト出版 \\\\
印刷所 & テスト印刷 \\\\
\\end{tabular}
~ \\\\
\\rule[0pt]{\\textwidth}{1pt} \\\\
\\rblatexColophonAfter \\\\
EOB
    assert_equal expected, colophon_tex
  end

end
