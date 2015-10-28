class UnitImagesController < ApplicationController
  before_action :set_image, only: [:destroy, :rotate]
  before_action :set_unit, except: [:destroy, :rotate]
  
  # POST /images
  # POST /images.json
  def create
    @image = @unit.images.build(image_params)
    
    # dropzone expects a json response code
    if @image.save(image_params)
      @unit.images << @image
      if params[:residential_listing_id] && !params[:residential_listing_id].empty?
        render json: { message: "success", fileID: @image.id, unitID: @unit.id, runitID: @unit.residential_listing.id },
          :status => 200
      elsif params[:commercial_listing_id] && !params[:commercial_listing_id].empty?
        render json: { message: "success", fileID: @image.id, unitID: @unit.id, cunitID: @unit.commercial_listing.id },
          :status => 200
      elsif params[:sales_listing_id] && !params[:sales_listing_id].empty?
        render json: { message: "success", fileID: @image.id, unitID: @unit.id, sunitID: @unit.sales_listing.id },
          :status => 200
      end
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
      img = Image.find(value[:id])
      if img.priority != value[:position]
        img.update_columns(priority: value[:position])
      end
    end

    render :nothing => true
  end

  def rotate
    if @image.rotate
      render json: { message: "File has been rotated +90 degrees" }
    else
      render json: { message: @image.errors.full_messages.join(',') }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    def set_unit
      if params[:residential_listing_id]
        @unit = ResidentialListing.find(params[:residential_listing_id]).unit
      elsif params[:commercial_listing_id]
        @unit = CommercialListing.find(params[:commercial_listing_id]).unit
      elsif params[:sales_listing_id]
        @unit = SalesListing.find(params[:sales_listing_id]).unit
      end
      #@unit = Unit.find(params[:unit_id])
    end

    def image_params
      params.permit(:file, :priority, :order)
    end

end
