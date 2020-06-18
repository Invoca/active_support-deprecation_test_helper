# ActiveSupport::DeprecationTestHelper

A test helper that removes `ActiveSupport::Deprecation` noise from being interlaced in your test output.  Instead this gem collects
any and all deprecation warnings that occur during your tests, and succinctly reports them at the end of the test run.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activesupport-deprecation_test_helper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesupport-deprecation_test_helper

## Usage
### Basic Configuration
In order to capture and report all deprecation warnings at the end of the test run, use one of the
following methods for configuration.

#### Configuring for Supported Test Frameworks
Currently the following test frameworks are supported out of the box:
- Minitest (`:minitest`)
- RSpec (`:rspec`)

In order to configure you test runs in `Minitest` add the following to your `test_helper.rb`
```ruby
require 'active_support/deprecation_test_helper'
ActiveSupport::DeprecationTestHelper.configure(:minitest)
```

And for `RSpec` add the following to your `spec_helper.rb` after your `RSpec.configure` block:
```ruby
require 'active_support/deprecation_test_helper'
ActiveSupport::DeprecationTestHelper.configure(:rspec)
```

#### Configuring for Unsupported Test Frameworks
If you are using an unsupported test framework and would like to use this gem, you'll need to add the
following pieces to your test setup.

1. Include `ActiveSupport::DeprecationTestHelper` into `ActiveSupport::Deprecation` using the following
```ruby
require 'active_support/deprecation_test_helper'
ActiveSupport::Deprecation.include ActiveSupport::DeprecationTestHelper
```
2. Report all unexpected warnings at the end of the test run with
```ruby
ActiveSupport::DeprecationTestHelper.report_unexpected_warnings
```

### Expected Deprecation Warnings
If you have some deprecations warnings that you're not going to resolve, and would like to omit them from the test run report, you can do the following

```ruby
ActiveSupport::DeprecationTestHelper.allow_warning("The full deprecation warning string")
```

Or you can use a regex if you would like to match a series of deprecation warnings

```ruby
ActiveSupport::DeprecationTestHelper.allow_warning(/will be removed from Rails 6\.0/)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Invoca/active_support-deprecation_test_helper.
