class UnitImagesController < ApplicationController
  before_action :set_image, only: [:destroy]
  before_action :set_unit, except: [:destroy]
  etag { current_user.id }
  
  # POST /images
  # POST /images.json
  def create
    @image = @unit.images.build(image_params)
    
    # dropzone expects a json response code
    @image.unit = @unit
    if @image.save(image_params)
      render json: { message: "success", fileID: @image.id, unitID: @unit.id }, :status => 200
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

  def sort
    params[:order].each do |key,value|
      Image.find(value[:id]).update_attribute(:priority, value[:position])
    end
    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    def set_unit
      if params[:residential_unit_id]
        @unit = ResidentialUnit.find(params[:residential_unit_id])
      elsif params[:commercial_unit_id]
        @unit = CommercialUnit.find(params[:commercial_unit_id])
      end
    end

    def image_params
      params.permit(:file, :priority, :order)
    end
end
