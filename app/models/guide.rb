class Guide < ActiveRecord::Base
  	attr_accessible :answer, :qgroup, :qtype, :question, :learned, :score, :notes
  	validates :question, :answer, presence: true

  	def pairing(parray)
	    if parray.count > 2
	      parray.sample(2) 	# gets 2 random questions from array
	    else
	      parray
	    end
	end

	def changepairorder(sarray)
	    if sarray.count > 2
	      @td = sarray.shift
	      sarray.push @td
	    else
	      sarray.reverse!
	    end
	    return sarray
	end
end
