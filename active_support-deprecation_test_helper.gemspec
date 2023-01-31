
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_support/deprecation_test_helper/version"

Gem::Specification.new do |spec|
  spec.name          = "activesupport-deprecation_test_helper"
  spec.version       = ActiveSupport::DeprecationTestHelper::VERSION
  spec.authors       = ["Invoca"]
  spec.email         = ["operations@invoca.com"]

  spec.summary       = "A test helper that removes `ActiveSupport::Deprecation` noise from being interlaced in your test output."
  spec.description   = [
    "A test helper that removes `ActiveSupport::Deprecation` noise from being interlaced in your test output.",
    "Instead this gem collects any and all deprecation warnings that occur during your tests, and succinctly reports them at the end of the test run."
  ].join(' ')
  spec.homepage      = "https://github.com/Invoca/active_support-deprecation_test_helper"

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'homepage_uri'      => 'https://github.com/Invoca/active_support-deprecation_test_helper',
    'source_code_uri'   => 'https://github.com/Invoca/active_support-deprecation_test_helper',
    'changelog_uri'     => 'https://github.com/Invoca/active_support-deprecation_test_helper/blob/master/CHANGELOG.md'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 5.2', '< 8'
end
