#
# TODO: This code is terrible! It was written when I had very little
# understanding of how Paperclip worked. I would re-write it, but at
# this point I don't have the time, and things work as they are.
# Should be updated at some point.
#
class ImagesController < ApplicationController
  skip_load_resource
  before_action :set_image, only: [:destroy]
  before_action :set_building, except: [:destroy]

  # POST /images
  # POST /images.json
  def create
    @image = @building.images.build(image_params)
#    @image.file.reprocess_without_delay!(:thumb)

    # dropzone expects a json response code
    @image.building = @building
    if @image.save(image_params)
      # @image.building.update_columns(updated_at: Time.now)
      render json: { message: "success", fileID: @image.id, bldgID: @building.id }, status: 200
    else
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @image.errors.full_messages.join(',')}, status: 400
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    if @image
      # @image.building.update_columns(updated_at: Time.now)
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

  def sort
    params[:order].each do |key,value|
      img = Image.find(value[:id])
      if img && img.priority != value[:position]
        img.update_columns(priority: value[:position])
        # img.building.update_columns(updated_at: Time.now)
      end
    end
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # noop
    end

    def set_building
      @building = Building.find(params[:building_id])
    end

    def image_params
      params.permit(:file, :building, :priority, :order)
    end
end
