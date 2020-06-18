# frozen_string_literal: true

require "active_support/deprecation_test_helper/version"
require "active_support/deprecation"
require "active_support/core_ext/object/inclusion"

module ActiveSupport
  module DeprecationTestHelper
    CONFIGURABLE_TEST_FRAMEWORKS = [:rspec, :minitest].freeze

    class << self
      def configure(test_framework)
        test_framework.in?(CONFIGURABLE_TEST_FRAMEWORKS) or raise "Unexpected test framework encountered. Supported frameworks are #{CONFIGURABLE_TEST_FRAMEWORKS.join(' ')}"

        ActiveSupport::Deprecation.include(self)

        case test_framework
        when :rspec
          RSpec.configuration.after(:all, &after_all_callback)
        when :minitest
          Minitest.after_run(&after_all_callback)
        end
      end

      def reset
        @allowed_warnings    = Set.new
        @unexpected_warnings = Set.new
      end

      def allow_warning(message_or_regex)
        unless message_or_regex.is_a?(String) || message_or_regex.is_a?(Regexp)
          raise ArgumentError, "Expected message_or_regex to be a String or a Regexp but was a #{message_or_regex.class.name}"
        end
        allowed_warnings << message_or_regex
      end

      def after_all_callback
        -> { unexpected_warnings.any? and warn unexpected_warnings_message }
      end

      def unexpected_warnings_message
        <<~EOS.chomp
          =====
          #{(['Unexpected Deprecation Warnings Encountered'] + unexpected_warnings.to_a).join("\n  ")}
          =====
        EOS
      end

      def track_warning(warning)
        if warning && !expected_warning?(warning)
          unexpected_warnings << warning
        end
      end

      protected

      attr_reader :unexpected_warnings, :allowed_warnings

      def expected_warning?(warning)
        allowed_warnings.any? { |allowed_warning| allowed_warning === warning }
      end
    end

    self.reset

    def deprecation_warning(*_args)
      super.tap { |warning| ActiveSupport::DeprecationTestHelper.track_warning(warning) }
    end

    def behavior
      [::ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]]
    end
  end
end
