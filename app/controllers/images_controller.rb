class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :set_building, except: [:destroy]

  # GET /images
  # GET /images.json
  # def index
  #   @images = Image.all
  # end

  # # GET /images/1
  # # GET /images/1.json
  # def show
  # end

  # GET /images/new
  def new
    #@image = Image.new
    @image = @building.images.build
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = @building.images.build(image_params)
    
    # dropzone expects a json response code
    @image.building = @building
    if @image.save(image_params)
      render json: { message: "success", fileID: @image.id, bldgID: @building.id }, :status => 200
    else 
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @image.errors.full_messages.join(',')}, :status => 400
    end

    # respond_to do |format|
    #   if @image.save
    #     format.html { redirect_to @image, notice: 'Image was successfully created.' }
    #     format.json { render :show, status: :created, location: @image }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @image.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  # def update
  #   respond_to do |format|
  #     if @image.update(image_params)
  #       format.html { redirect_to @image, notice: 'Image was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @image }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @image.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.file = nil
    if @image.destroy    
      render json: { message: "File deleted from server" }
    else
      render json: { message: @image.errors.full_messages.join(',') }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    def set_building
      if params[:building_id]
        @building = Building.find(params[:building_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.permit(:file, :building)
      #params[:image].permit(:file, :building)
    end
end
