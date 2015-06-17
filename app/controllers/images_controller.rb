class ImagesController < ApplicationController
  before_action :set_image, only: [:destroy]
  before_action :set_building, except: [:destroy]

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
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
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

    def image_params
      params.permit(:file, :building)
      #params[:image].permit(:file, :building)
    end
end
