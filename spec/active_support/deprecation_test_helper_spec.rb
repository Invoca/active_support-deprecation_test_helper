# frozen_string_literal: true

RSpec.describe ActiveSupport::DeprecationTestHelper do
  before { described_class.reset }

  describe "VERSION" do
    subject { ActiveSupport::DeprecationTestHelper::VERSION }
    it { should_not be_nil }
  end

  describe "#configure" do
    subject { described_class.configure }

    describe "when running in Minitest" do
      let(:minitest_stub) { Class.new }

      before { stub_const("Minitest", minitest_stub) }

      it 'configures an after all hook' do
        expect(Minitest).to receive(:after_run).with(described_class.after_all_callback)
        subject
      end
    end

    describe "when running in RSpec" do
      it 'configures an after all hook' do
        expect(RSpec.configuration).to receive(:after).with(:all, described_class.after_all_callback)
        subject
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
      before  { expect(described_class).to receive(:report_unexpected_warnings).and_return(true) }
      subject { callback.call }
      it { should eq(true) }
    end
  end

  describe "#report_unexpected_warnings" do
    before  { allow(described_class).to receive(:unexpected_warnings).and_return(unexpected_warnings) }
    subject { described_class.report_unexpected_warnings }

    describe "when there were no unexpected warnings" do
      let(:unexpected_warnings) { [] }
      before { expect(described_class).to_not receive(:warn) }
      it { should eq(true) }
    end

    describe "when there were unexpected warnings" do
      let(:unexpected_warnings) { ["hello world"] }
      let(:expected_warning) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
          hello world
        =====
      EOS
      before { expect(described_class).to receive(:warn).with(expected_warning).and_return(true) }
      it { should eq(true) }
    end
  end

  describe "when ActiveSupport::DeprecationTestHelper is configured" do
    let(:after_all_callback) { double(Proc) }
    subject { described_class.report_unexpected_warnings }

    before do
      expect(RSpec.configuration).to receive(:after).with(:all, described_class.after_all_callback)
      described_class.configure
      described_class.allow_warning /this is allowed/
    end

    describe "when deprecation warning occurs that is allowed" do
      before do
        ActiveSupport::Deprecation.deprecation_warning(:hello_world, "this is allowed")
        expect(described_class).to_not receive(:warn)
      end

      it { should eq(true) }
    end

    describe "when deprecation warning occurs that is not allowed" do
      let(:expected_warning) { <<~EOS.chomp }
        =====
        Unexpected Deprecation Warnings Encountered
          hello_world is deprecated and will be removed from Rails 6.0 (this is not allowed)
        =====
      EOS

      before do
        expect(described_class).to receive(:warn).with(expected_warning).and_return(true)
        ActiveSupport::Deprecation.deprecation_warning(:hello_world, "this is not allowed")
      end

      it { should eq(true) }
    end
  end
end
