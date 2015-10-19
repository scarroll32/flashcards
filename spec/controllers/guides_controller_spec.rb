require "rails_helper"

describe GuidesController do

	describe "Learning" do
		it "should select a pair of questions to start learning" do
			@guide1 = FactoryGirl.create(:guide)
			@guide2 = FactoryGirl.create(:guide)
			@guide3 = FactoryGirl.create(:guide)
			@guide4 = FactoryGirl.create(:guide)

			@question = Guide.find(@guide1.id)
    		@question.update_attributes(:score => 0, :learned => 0)
			post "selectquestions", :qselect => [@guide1.id, @guide2.id, @guide3.id, @guide4.id], :learn => "Learn"
			session[:lpair].should_not be_empty
		end

		it "should not select a pair of questions to start learning" do
			post "selectquestions", :learn => "Learn"
			session[:lpair].should be_nil
		end

		it "should mark question as learned when clicks ok button" do
			@guide1 = FactoryGirl.create(:guide)
			session[:lpair] = [@guide1.id]
			get "learningnext"
			@guide = Guide.find(@guide1.id)
			@guide.learned.should == 1
		end

		it "should go to review with the pair of learned questions once learning is finished" do
			@guide1 = FactoryGirl.create(:guide)
			session[:lpair] = [@guide1.id]
			get "learningnext"
			session[:lpair].should be_empty
			response.should redirect_to "/guides/learningexam"
		end

		it "should get next question when user gives right answer" do
			@guide1 = FactoryGirl.create(:guide)
			session[:lpair] = [@guide1.id]
			session[:lepair] = [@guide1.id]
			session[:lselect] = []
			post "lanswervalidate", :your_answer => "#{@guide1.answer}"
			response.should redirect_to "/guides/learningexam"
		end

		it "should go to review with all learned questions once learning is finished" do
			@guide1 = FactoryGirl.create(:guide)
			session[:lepair] = []
			session[:leselect] = [@guide1.id]
			get "learningexam"
			response.should redirect_to "/guides/examination"
		end
	end

	describe "Review" do

		it "score will be 0 once user clicks Skip button" do
			@guide1 = FactoryGirl.create(:guide)
			session[:pair] = [@guide1.id]
			session[:wrong] = []
			session[:eselect] = []
			get "skip"
			@question = Guide.find(@guide1.id)
			@question.score.should == 0
		end

		it "marks as non learned once user clicks Skip button" do
			@guide1 = FactoryGirl.create(:guide)
			session[:pair] = [@guide1.id]
			session[:wrong] = []
			session[:eselect] = []
			get "skip"
			@question = Guide.find(@guide1.id)
			@question.learned.should == 0
		end

		it "score should be increased to 1 when clicks yes button" do
			@guide1 = FactoryGirl.create(:guide)
			session[:pair] = [@guide1.id]
			session[:wrong] = []
			session[:eselect] = []
			@uquestion = Guide.find(@guide1.id)
			get "answerrightyes"
			@question = Guide.find(@guide1.id)
			@question.score.should == @uquestion.score + 1
		end

		it "score should be 0 when clicks no button" do
			@guide1 = FactoryGirl.create(:guide)
			session[:pair] = [@guide1.id]
			session[:wrong] = []
			get "answerrightno"
			@question = Guide.find(@guide1.id)
			@question.score.should == 0
		end

		it "review is over once all items are reviewed" do
			session[:pair] = []
			get "examination"
			assigns(:message).should == 1
		end
		
	end
end