class DocumentsController < ApplicationController
  before_action :set_document, only: [:destroy]
  before_action :set_unit, except: [:destroy]
  etag { current_user.id }
  
  # POST /documents
  # POST /documents.json
  def create
    @document = @unit.documents.build(document_params)
    
    # dropzone expects a json response code
    if @document.save(document_params)
      @unit.documents << @document
      if params[:residential_listing_id] && !params[:residential_listing_id].empty?
        render json: { message: "success", fileID: @document.id, unitID: @unit.id, runitID: @unit.residential_listing.id },
          :status => 200
      elsif params[:commercial_listing_id] && !params[:commercial_listing_id].empty?
        render json: { message: "success", fileID: @document.id, unitID: @unit.id, cunitID: @unit.commercial_listing.id },
          :status => 200
      elsif params[:sales_listing_id] && !params[:sales_listing_id].empty?
        render json: { message: "success", fileID: @document.id, unitID: @unit.id, sunitID: @unit.sales_listing.id },
          :status => 200
      end
    else 
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @document.errors.full_messages.join(',')}, :status => 400
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.file = nil
    if @document.destroy
      render json: { message: "File deleted from server" }
    else
      render json: { message: @document.errors.full_messages.join(',') }
    end
  end

  def sort
    # TODO

    params[:order].each do |key,value|
      doc = Document.find(value[:id])
      if doc.priority != value[:position]
        doc.update_columns(priority: value[:position])
      end
    end

    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    def set_unit
      if params[:residential_listing_id]
        @unit = ResidentialListing.find(params[:residential_listing_id]).unit
      elsif params[:commercial_listing_id]
        @unit = CommercialListing.find(params[:commercial_listing_id]).unit
      elsif params[:sales_listing_id]
        @unit = SalesListing.find(params[:sales_listing_id]).unit
      end
    end

    def document_params
      params.permit(:file, :priority, :order)
    end

end
