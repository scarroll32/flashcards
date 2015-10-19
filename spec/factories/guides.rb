FactoryGirl.define do 
	factory :guide do |g| 
		g.sequence(:id) {|n| n}
	  	g.sequence(:question) { |n| "q#{n}"}
	  	g.sequence(:answer) { |n| "a#{n}"}
	  	g.learned 0
	  	g.score 0
	end 
end