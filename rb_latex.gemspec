lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rb_latex/version"

Gem::Specification.new do |spec|
  spec.name          = "rb_latex"
  spec.version       = RbLatex::VERSION
  spec.authors       = ["takahashim"]
  spec.email         = ["maki@rubycolor.org"]

  spec.summary       = %q{wrapper library of LaTeX}
  spec.description   = %q{wrapper library of LaTeX}
  spec.homepage      = "https://github.com/takahashim/rb_latex"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.2"
  spec.add_development_dependency "test-unit-notify"
  spec.add_development_dependency "terminal-notifier"
end
