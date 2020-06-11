# frozen_string_literal: true

require "active_support/deprecation_test_helper/version"
require 'active_support/deprecation'

module ActiveSupport
  module DeprecationTestHelper
    class << self
      def configure
        defined?(Minitest) || defined?(RSpec) or raise 'Unexpected test suite encountered. This only supports Rspec and Minitest'

        ActiveSupport::Deprecation.include(self)

        if defined?(Minitest)
          Minitest.after_run(after_all_callback)
        elsif defined?(RSpec)
          RSpec.configuration.after(:all, after_all_callback)
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
        @after_all_callback ||= -> { report_unexpected_warnings }
      end

      def report_unexpected_warnings
        unexpected_warnings.empty? or warn <<~EOS.chomp
          =====
          Unexpected Deprecation Warnings Encountered
            #{unexpected_warnings.to_a.join("\n  ")}
          =====
        EOS
      end

      def track_warning(warning)
        if warning && !expected_warning?(warning)
          unexpected_warnings << warning
        end
      end

      protected

      def unexpected_warnings
        @unexpected_warnings ||= Set.new
      end

      def allowed_warnings
        @allowed_warnings ||= Set.new
      end

      def expected_warning?(warning)
        allowed_warnings.any? do |allowed_warning|
          case allowed_warning
          when Regexp
            warning.match?(allowed_warning)
          else
            warning == allowed_warning
          end
        end
      end
    end

    def deprecation_warning(*args)
      super.tap { |warning| ActiveSupport::DeprecationTestHelper.track_warning(warning) }
    end

    def behavior
      [::ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]]
    end
  end
end
