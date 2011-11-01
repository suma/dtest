# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  version_file = "lib/dtest/version.rb"
  version = File.read("VERSION").strip
  File.open(version_file, "w") {|f|
    f.write <<EOF
module DTest

VERSION = '#{version}'

end
EOF
  }

  gem.name        = %q{dtest}
  gem.version     = version
  gem.authors     = ["Shuzo Kashihara"]
  gem.email       = %q{suma@sourceforge.jp}
  gem.description = "DTest is a testing tool to describe integrating test for distributed systems."
  gem.summary     = gem.description

  gem.homepage      = "https://github.com/suma/dtest"
  gem.has_rdoc      = false
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.required_ruby_version = '=> 1.8.7'
  gem.add_dependency "rake", ">= 0.9.2"
  gem.add_dependency "rspec", ">= 1.2.3"
end
