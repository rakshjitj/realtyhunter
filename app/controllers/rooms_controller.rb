class RoomsController < ApplicationController
	#load_and_authorize_resource
  #skip_load_resource only: [:create,:edit, :room_update]
  def index
    @residential_listing = ResidentialListing.where(roomshare_department: true)
  end

  def edit
    @residential_unit = ResidentialListing.find(params[:id])
    if @residential_unit.rooms.blank?
      @kennel = []
      @residential_unit.beds.to_i.times do
        @kennel << Room.new
      end
    else
      @kennel = []
      @residential_unit.beds.to_i.times do |a|
        #abort @residential_unit.rooms[a].inspect
        @kennel << @residential_unit.rooms[a]
      end
      @kennel = @kennel.compact
      @kennel = @kennel.sort {|x,y| -(y <=> x)}
      #render "edit_existed"
    end
    #abort @residential_listing.inspect
  end

  def room_update
    @residential_unit = ResidentialListing.find(params[:id])
    @residential_unit.update(rooms_description: params[:unit_description], room_syndication: params[:room_syndication])
    #abort params[:unit_status].inspect
    @residential_unit.unit.update(status: params[:unit_status].downcase, primary_agent_for_rs: params[:primary_agent_for_rs], rent: params[:unit_rent])
    #abort params[:unit_image].nil?.inspect
    # if !params[:unit_image].nil?
    #   @residential_unit.unit.images.create(file: params[:unit_image], unit_id: @residential_unit.unit.id)
    # end
    if @residential_unit.rooms.blank?
      if params.has_key?("room")
        @rooms = Room.create(room_params(params["room"]))
      else
        params["rooms"].each do |room|
          if room["file"].present?
            @rooms =  Room.create(room_params(room))
            room["file"].each do |r|
              @rooms.images.create(file: r, room_id: @rooms.id)
            end
          else
            @rooms =  Room.create(room_params(room))
          end
        end
      end
      if @rooms.save
        redirect_to room_path(@residential_unit)
      else
      end
    else

      params["rooms"].each do |room|
        #abort params[:rooms][room].inspect
        params['rooms'][room].each do |key,value|
          #abort params['rooms'][room][id].inspect
          if key != "file"
            r = {key => value}
          end
          room = room.to_i
          @room = Room.find(room)
          if key == "file"
            # for j in 0..value.count
            #   i = {"file" => value[j], :room_id => @room.id}
            #   @room.images.create(i)
            # end
            #abort @image.inspect
            #abort value.count.inspect
            value.each do |v|
              i = {key => v, :room_id => @room.id}
              #abort @i.inspect
              #abort i.inspect
              @room.images.create(i)
            end
            # abort @i.inspect
          end
          if key != "file"
            @room.update_attributes(r)
          end
          

      end
      #image priority define for rooms
      if !params["image"].blank?
        params["image"].each do |image, val|
          @image = Image.find(image)
          @image.update_attributes(priority: val)
        end
      end
        #abort @room.inspect
      end
        redirect_to room_path(@residential_unit)
    end
  end

  def show
    @residential_unit = ResidentialListing.find(params[:id])
  end

  def room_image_delete
    @image = Image.find(params[:id])
    if @image.destroy
      
      respond_to do |f|
        f.html { redirect_to :back }
        f.js
      end
    end

  end

	private
	  # def room_params
   #    params.permit(:id,:name, :rent, :status, :description, :residential_listing_id)
   #  end
    def room_params(my_params)
      my_params.permit(:id,:name, :rent, :status, :description, :residential_listing_id, :file, :image)
    end
end
