class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    if user = User.find(params[:user_id])
      @submissions = Submission.find_all_by_user_id user.id
    else
      @submissions = Submission.all
    end
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    redirect_to new_user_session_path unless current_user
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
      `mkdir #{Rails.root}/meshes/#{@submission.id}`
      #`cp #{image_path} #{Rails.root}/meshes/#{@submission.id}`
      generate
      logger.info `rsync -aP /opt/nginx/apps/botproof3d.co/current/meshes/ /tmp/botproof/meshes/`
      logger.info `cd /tmp/botproof/ && git add meshes`
      @submission.save

      sleep 5
    end

    def generate
      command = "#{get_binary_path} -i #{image_path} -o #{Rails.root}/meshes/#{@submission.id}/#{image_name}.stl"
      `#{command}`

      repair_path = "#{Rails.root}/meshes/#{@submission.id}/#{image_name}_repaired.stl"
      mlx_path = "#{Rails.root}/public/mxls/holes.mlx"
      binary_path = get_binary_path
      command = "#{binary_path} -i #{image_path} -o #{repair_path} -s #{mlx_path} -om vc fq wn"
      `#{command}`
      @submission.repair_image = repair_path
    end

    def convert_stl_to_obj
      command = "#{get_binary_path} -i #{image_path} -o #{Rails.root}/meshes/#{@submission.id}/#{image_name}.obj"
    end

    def image_name
      @submission.image.to_s.split("/").last
    end

    def image_path
      "#{Rails.root}/public/#{@submission.image}"
    end

    def get_binary_path
      if Rails.env == 'production'
        meshlabserver = 'xvfb-run -a /usr/bin/meshlabserver'
      else
        meshlabserver = '/usr/local/bin/meshlabserver'
      end
    end
end
