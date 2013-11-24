class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    @submissions = Submission.all
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
  end

  # GET /submissions/1/edit
  def edit
  end

  # POST /submissions
  # POST /submissions.json
  def create
    @submission = Submission.new(submission_params)

    respond_to do |format|
      if @submission.save
        create_repaired_mesh
        format.html { redirect_to @submission, notice: 'Submission was successfully created.' }
        format.json { render action: 'show', status: :created, location: @submission }
      else
        format.html { render action: 'new' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1
  # PATCH/PUT /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:user_id, :name, :rating, :orientation, :description, :image)
    end

    def create_repaired_mesh
      image_name = @submission.image.to_s.split("/").last
      image_path = "#{Rails.root}/public/#{@submission.image}"
      `mkdir #{Rails.root}/meshes/#{@submission.id}`
      #`cp #{image_path} #{Rails.root}/meshes/#{@submission.id}`
      command = "#{get_binary_path} -i #{image_path} -o #{Rails.root}/meshes/#{@submission.id}/#{image_name}.stl"
      `#{command}`
      repair_path = "#{Rails.root}/meshes/#{@submission.id}/#{image_name}"
      mlx_path = "#{Rails.root}/public/mxls/holes.mlx"
      binary_path = get_binary_path
      command = "#{binary_path} -i #{image_path} -o #{repair_path}_repaired.stl -s #{mlx_path} -om vc fq wn"
      `#{command}`

      `cd #{Rails.root} && git checkout master && git pull`
      `cd #{Rails.root} && git add #{Rails.root}/meshes`
      `cd #{Rails.root} && git commit -m '#{@submission.id} - #{image_name}'`
      `cd #{Rails.root} && git push`
      `cd #{Rails.root} && git checkout deploy`


      @submission.repair_image = repair_path
      @submission.save
    end

    def get_binary_path
      if Rails.env == 'production'
        meshlabserver = 'xvfb-run /usr/bin/meshlabserver'
      else
        meshlabserver = '/usr/local/bin/meshlabserver'
      end
    end
end