class UnitImagesController < ApplicationController
  skip_authorize_resource
  before_action :set_image, only: [:destroy, :display, :display_floor_image, :display_floor_image_sales]
  before_action :set_unit, except: [:destroy, :display, :display_floor_image, :display_floor_image_sales]

  # POST /images
  # POST /images.json
  def create
    @image = @unit.images.build(image_params)
#    @image.file.reprocess_without_delay!(:thumb)

    # dropzone expects a json response code
    if @image.save(image_params)
      @unit.images << @image
      update_listing_timestamp(@image)

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
    if @image
      update_listing_timestamp(@image)
      @image.file = nil
      if @image.destroy
        render json: { message: "File deleted from server" }
      else
        render json: { message: @image.errors.full_messages.join(',') }
      end
    else
      # if a user clicks a delete link twice in rapid succession,
      # just ignore it
      render nothing: true
    end
  end

  def display
    if @image
      if @image.display_on_website == true
        @image.update_columns(display_on_website: false)
      elsif @image.display_on_website == false
        @image.update_columns(display_on_website: true)
      end
    else
      render nothing: true
    end
  end

  def display_floor_image
    if @image
      if @image.floorplan == true
        @image.update_columns(floorplan: false)
      elsif @image.floorplan == false
        @image.update_columns(floorplan: true)
      end
    else
      render nothing: true
    end
  end

  def display_floor_image_sales
    if @image
      if @image.floorplan == true
        @image.update_columns(floorplan: false)
      elsif @image.floorplan == false
        @image.update_columns(floorplan: true)
      end
    else
      render nothing: true
    end
  end

  def sort
    params[:order].each do |key,value|
      img = Image.find(value[:id])
      if img && img.priority != value[:position]
        update_listing_timestamp(img)
        img.update_columns(priority: value[:position])
      end
    end

    render :nothing => true
  end

  # def rotate
  #   if @image.rotate
  #     render json: { message: "File has been rotated +90 degrees" }
  #   else
  #     render json: { message: @image.errors.full_messages.join(',') }
  #   end
  # end

  private
    def update_listing_timestamp(img)
      if img.unit.residential_listing
        listing = img.unit.residential_listing
        # img.unit.residential_listing.update_columns(updated_at: Time.now)
      elsif img.unit.commercial_listing
        listing = img.unit.commercial_listing
        # img.unit.commercial_listing.update_columns(updated_at: Time.now)
      elsif img.unit.sales_listing
        listing = img.unit.sales_listing
        # img.unit.sales_listing.update_columns(updated_at: Time.now)
      end

      if listing
        listing.update_columns(updated_at: Time.now)
      end
    end

    def set_image
      @image = Image.find(params[:id])
      # puts "********** set_image ******** #{@image.inspect}"
    rescue ActiveRecord::RecordNotFound
      # noop
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
