require "rails_helper"

describe "Question" do
	it "should not be valid" do
		guide = Guide.new
		guide.should_not be_valid
	end
end