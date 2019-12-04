lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "videocloud_service/version"

Gem::Specification.new do |spec|
  spec.name          = "videocloud_service"
  spec.version       = VideocloudService::VERSION
  spec.authors       = ["Marina Popp"]
  spec.email         = ["marina.popp@brightcove.com"]

  spec.summary       = %q{Brightcove videocloud service Wrapper for Ruby}
  spec.description   = %q{Brightcove videocloud service Wrapper for Ruby}
  spec.homepage      = "https://github.com/marinapopp/videocloud_service"
  spec.license       = "MIT"

  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "aws-sdk-s3", "~> 1"
  spec.add_runtime_dependency "http", "~> 3.0.0"
  spec.add_runtime_dependency "activemodel"
  
end
