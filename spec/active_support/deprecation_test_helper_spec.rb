# frozen_string_literal: true

RSpec.describe ActiveSupport::DeprecationTestHelper do
  before { described_class.reset }

  describe "VERSION" do
    subject { ActiveSupport::DeprecationTestHelper::VERSION }
    it { should_not be_nil }
  end

  describe "#configure" do
    let(:after_all_callback) { -> {} }
    subject { described_class.configure(test_framework) }
    before { allow(described_class).to receive(:after_all_callback).and_return(after_all_callback) }

    describe "when rspec is specified" do
      let(:test_framework) { :rspec }
      before { expect(RSpec.configuration).to receive(:after).with(:suite) }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    describe "when minitest is specified" do
      let(:test_framework) { :minitest }
      let(:minitest_stub) { Class.new }

      before do
        stub_const("Minitest", minitest_stub)
        expect(minitest_stub).to receive(:after_run)
      end

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    describe "when an unsupported framework is specified" do
      let(:test_framework) { :unsupported }

      it 'raises an error' do
        expect { subject }.to raise_error(/Unexpected test framework encountered/)
      end
    end
  end

  describe "#allow_warning" do
    subject { -> { described_class.allow_warning(allowed_warning) } }

    describe "when provided a string" do
      let(:allowed_warning) { "hello" }
      it { should_not raise_error }
    end

    describe "when provided a regular expression" do
      let(:allowed_warning) { /hello/ }
      it { should_not raise_error }
    end

    describe "when not provided a string or regular expression" do
      let(:allowed_warning) { Class.new }
      it { should raise_error(ArgumentError, "Expected message_or_regex to be a String or a Regexp but was a Class") }
    end
  end

  describe "#after_all_callback" do
    let(:callback) { described_class.after_all_callback }
    subject { callback }

    it { should be_a(Proc) }

    describe "when executed" do
      subject { callback.call }
      before  { allow(described_class).to receive(:unexpected_warnings).and_return(unexpected_warnings) }

      describe "when there are unexpected exceptions" do
        let(:unexpected_warnings) { ["hello world"] }
        before { expect(described_class).to receive(:warn).and_return(true) }
        it { should eq(true) }
      end

      describe "when there are no unexpected exceptions" do
        let(:unexpected_warnings) { [] }
        before { expect(described_class).to_not receive(:warn) }
        it { should eq(false) }
      end
    end
  end

  describe "#unexpected_warnings_message" do
    before  { allow(described_class).to receive(:unexpected_warnings).and_return(unexpected_warnings) }
    subject { described_class.unexpected_warnings_message }

    describe "when there were no unexpected warnings" do
      let(:unexpected_warnings) { [] }
      let(:expected_message) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
        =====
      EOS
      before { expect(described_class).to_not receive(:warn) }
      it { should eq(expected_message) }
    end

    describe "when there were unexpected warnings" do
      let(:unexpected_warnings) { ["hello world"] }
      let(:expected_message) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
          hello world
        =====
      EOS
      it { should eq(expected_message) }
    end
  end

  describe "when ActiveSupport::DeprecationTestHelper is configured" do
    subject { described_class.unexpected_warnings_message }

    before do
      expect(RSpec.configuration).to receive(:after).with(:suite)
      described_class.configure(:rspec)
      described_class.allow_warning /this is allowed/
    end

    describe "when deprecation warning occurs that is allowed" do
      let(:expected_message) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
        =====
      EOS

      before do
        deprecator = ActiveSupport::Deprecation.new("1.0", "active_support-deprecation_test_helper")
        deprecator.deprecation_warning(:hello_world, "this is allowed")
      end

      it { should eq(expected_message) }
    end

    describe "when deprecation warning occurs that is not allowed" do
      let(:expected_warning) { /hello_world is deprecated and will be removed/ }
      let(:expected_message) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
          hello_world is deprecated and will be removed .*
        =====
      EOS

      before do
        deprecator = ActiveSupport::Deprecation.new("1.0", "active_support-deprecation_test_helper")
        deprecator.deprecation_warning(:hello_world, "this is not allowed")
      end

      it { should match(expected_message) }
    end
  end
end
