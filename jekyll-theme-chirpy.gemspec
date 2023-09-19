# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-chirpy"
  spec.version       = "1.0.0"
  spec.authors       = ["9xN"]
  spec.email         = ["0@fbi.ac"]

  spec.summary       = "My website."
  spec.homepage      = "https://github.com/9xN/9xN.github.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f|
    f.match(%r!^((_(includes|layouts|sass|data)|assets)\/|README|LICENSE)!i)
  }

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/9xN/9xN.github.io/issues",
    "documentation_uri" => "https://github.com/9xN/9xN.github.io/#readme",
    "homepage_uri"      => "https://github.com/9xN/9xN.github.io",
    "source_code_uri"   => "https://github.com/9xN/9xN.github.io",
    "wiki_uri"          => "https://github.com/9xN/9xN.github.io/wiki",
    "plugin_type"       => "theme"
  }

  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "jekyll", "~> 4.3"
  spec.add_runtime_dependency "jekyll-paginate", "~> 1.1"
  spec.add_runtime_dependency "jekyll-redirect-from", "~> 0.16"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.7"
  spec.add_runtime_dependency "jekyll-archives", "~> 2.2"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "jekyll-include-cache", "~> 0.2"

end
