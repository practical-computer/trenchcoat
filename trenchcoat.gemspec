# frozen_string_literal: true

require_relative "lib/trenchcoat/version"

Gem::Specification.new do |spec|
  spec.name = "trenchcoat"
  spec.version = Trenchcoat::VERSION
  spec.authors = ["Thomas Cannon"]
  spec.email = ["tcannon00@gmail.com"]

  # rubocop:disable Layout/LineLength
  spec.summary = "A concern to quickly scaffold custom forms based on existing ActiveRecord models, like 3 kids stacked up in a trenchcoat."
  spec.description = "Adds a `Trenchcoat` concern that you can use to write an ActiveModel class based on an existing record, that can also quack like the record."
  # rubocop:enable Layout/LineLength
  spec.homepage = "https://github.com/practical-computer/trenchcoat"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/practical-computer/trenchcoat"
  spec.metadata["changelog_uri"] = "https://github.com/practical-computer/trenchcoat"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activemodel", ">= 7.0"
  spec.add_dependency "activerecord", ">= 7.0"
  spec.add_dependency "activesupport", ">= 7.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
