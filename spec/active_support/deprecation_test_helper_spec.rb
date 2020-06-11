# frozen_string_literal: true

RSpec.describe ActiveSupport::DeprecationTestHelper do
  it "has a version number" do
    expect(ActiveSupport::DeprecationTestHelper::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
