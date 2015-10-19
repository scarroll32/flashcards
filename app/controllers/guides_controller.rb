class GuidesController < ApplicationController
  helper_method :sort_column, :sort_direction 

  def index
    if params[:sort].blank?       # checks whether sorting is selected
      @guides = Guide.all
    else
      @guides = Guide.order(params[:sort] + ' ' + params[:direction])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guides }
    end
  end

  def show
    @guide = Guide.find(params[:id])    # Shows Particlular question details

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guide }
    end
  end

  def new
    @guide = Guide.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guide }
    end
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def create
    @guide = Guide.new(params[:guide])

    respond_to do |format|
      if @guide.save                # creates question and redirects to home page
        format.html { redirect_to root_path, notice: 'Question was successfully created.' }
        format.json { render json: @guide, status: :created, location: root_path }
      else                          # Shows errors when there are errors
        format.html { render action: "new" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @guide = Guide.find(params[:id])

    respond_to do |format|
      if @guide.update_attributes(params[:guide])   # updates the selected question
        format.html { redirect_to @guide, notice: 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @guide = Guide.find(params[:id])
    @guide.destroy                    # deletes the specific question

    respond_to do |format|
      format.html { redirect_to guides_url }
      format.json { head :no_content }
    end
  end

  def learning                      # Processes when clicks "learn" button
    getquestion()                   # get question for learning
    @maxlearn = Guide.maximum(:learned)   # instance variable to show a popup when user starts learning for the first time
  end

  def learningnext                  # processes when press 'ok' button
    @uquestion = Guide.find(session[:lpair][0])
    @uquestion.update_attributes(:learned => 1) # mark the question as learned
    session[:lpair].shift  
    getquestion()                   # get the nex question for learning
  end

  def examination                   # processes when press 'review' button
    unless session[:pair].empty?
      @question = Guide.find(session[:pair][0])
    else
      @message = 1                  # instance variable to complete review process.
    end
  end

  def answervalidate                # processes when press 'submit button' in review process
    @id = params[:id]
    @question = Guide.find(@id)
    if @question.answer == params[:your_answer] # checks whether answer is right or not
      session[:pair].shift          # deletes the answered question from pair
      pairnext()                    # Inserts new question into pair
      deletewrong()                 # Deletes the answered question from wrong array
      @question.update_attributes(:score => @question.score + 1,:learned => 1)                      # Increase the score for answered question
      redirect_to guides_examination_path, :remote=> true
    end  
  end

  def answerrightyes                # processes when press 'yes' button in review process
    @id = session[:pair][0]
    @uquestion = Guide.find(@id)
    @uquestion.update_attributes(:score => @uquestion.score + 1, :learned => 1)
    session[:pair].shift
    pairnext()
    deletewrong()    
    redirect_to guides_examination_path, :remote=> true
  end

  def answerrightno                # processes when press 'no' button in review process
    @uquestion = Guide.find(session[:pair][0])
    @uquestion.update_attributes(:score => 0, :learned => 1) # updates the score to 0 and marks as non-learned for the wrongly answered question
    unless session[:wrong].include?(session[:pair][0])  # include the wrongly answered question into "wrong" pair to show question again to user
      session[:wrong].push session[:pair][0]
    end
    session[:pair] = Guide.new.changepairorder(session[:pair])
    redirect_to guides_examination_path, :remote=> true
  end

  def skip                # processes when press 'skip' button in review process
    @id = session[:pair][0]
    @question = Guide.find(@id)
    @question.update_attributes(:score => 0, :learned => 0)
    if session[:wrong].include?(@id)
      session[:wrong].delete(@id)
    end
    session[:pair].shift
    pairnext()
    redirect_to guides_examination_path, :remote=> true
  end

  def sort_column           # sorting the selected column  
    Guide.column_names.include?(params[:sort]) ? params[:sort] : "question"    
  end  
      
  def sort_direction        # sort the columns as ascending or descending
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc" 
  end 

  def selectquestions       # select the questions which are checked
    if params[:qselect].nil?  # Gives alert none of the questions selected for learn or review
      redirect_to root_path, notice: "You did not choose any questions."
    else
      @lnselect = Array.new   # Array to store non learned questions
      @lyselect = Array.new   # Array to store learned questions
      session[:wrong] = Array.new # Array to store wrongly answered questions

      params[:qselect].each do |id|
        if Guide.find(id).learned == 0
          @lyselect.push id
        else
          @lnselect.push id
        end
      end
      if params[:learn].nil? or @lyselect.count == 0    # When review button clicked or count of learned items = 0
        session[:pair] = Guide.new.pairing(@lnselect)
        session[:eselect] = @lnselect - session[:pair]
        redirect_to guides_examination_path
      else                                              # When learn button clicked
        session[:lpair] = Guide.new.pairing(@lyselect)  # takes 2 questions for learning from non learned questions
        session[:lepair] = session[:lpair].inject([]) { |a,element| a << element.dup }    # Duplicates the array for reviewing the learned pair after completes learning
        session[:leselect] = params[:qselect] # store the selected questions to start review process when learn is completed
        session[:lnselect] = @lnselect
        session[:lselect] = @lyselect - session[:lpair] # array of non learned questions
        redirect_to guides_learning_path
      end
    end
  end

  def resetquestions              # processes when clicks "reset" button
    Guide.delete_all              # Deletes all questions from the database
    redirect_to root_path, :alert => "Data has been reset"
  end 

  def pairnext()                  # Inserts next question into pair in review process
    unless session[:eselect].empty?
      @tarray = session[:eselect].sample(1)
      session[:eselect] = session[:eselect] - @tarray
      session[:pair].push @tarray[0]
    end
  end

  def deletewrong()              # Deletes question from wrongly answered array
    if session[:wrong].include?(@id)
      session[:pair].push @id
      session[:wrong].delete(@id)
    end
  end

  def getquestion()             # gets the next question for learning
    if session[:lpair].empty?
      redirect_to guides_learningexam_path # starts review process for the learned questions
    else
      @question = Guide.find(session[:lpair][0])
    end
  end

  def learningexam            # starts review process for the learned questions
    if session[:lepair].empty?
      session[:pair] = Guide.new.pairing(session[:leselect])
      session[:eselect] = session[:leselect] - session[:pair]
      redirect_to guides_examination_path
    else
      @question = Guide.find(session[:lepair][0])
    end
  end

  def lanswervalidate         # validates the answer in learning process
    @question = Guide.find(session[:lepair][0])   
    if @question.answer == params[:your_answer]
      @question.update_attributes(:score => @question.score + 1,:learned => 1)
      lanswerright()
    end    
  end

  def lanswerrightyes         # processes when clicks "yes" button in learn process
    @question = Guide.find(session[:lepair][0])
    @question.update_attributes(:score => @question.score + 1,:learned => 1)
    lanswerright()
  end

  def lanswerrightno        # processes when clicks "no" button in learn process
    @uquestion = Guide.find(session[:lepair][0])
    @uquestion.update_attributes(:score => 0, :learned => 1)
    session[:lepair] = Guide.new.changepairorder(session[:lepair])
    redirect_to guides_learningexam_path, :remote=> true
  end

  def lskip                 # processes when clicks "skip" button in learn process
    @question = Guide.find(session[:lepair][0])
    @question.update_attributes(:score => 0, :learned => 0)
    lanswerright()
  end

  def lanswerright()
    session[:lepair].shift
    unless session[:lselect].empty?
      @tarray = session[:lselect].sample(1) # gets the next random question for learning
      session[:lpair].push @tarray[0]
      session[:lepair].push @tarray[0]
      session[:lselect] = session[:lselect] - @tarray
      redirect_to guides_learning_path
    else
      redirect_to guides_learningexam_path
    end 
  end
end
