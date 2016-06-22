module API
  module V1

    # TODO: consider returning only building data and removing landlord data from here. keep the
    # landlord ID below.

    class BuildingsController < ApiController
      include API::V1::NestioInterface

      def index
        # pagination
        per_page = 50

        buildings = buildings_search()

        # updated_at
        if building_params[:changed_at] && !building_params[:changed_at].empty?
          time = Time.parse(building_params[:changed_at]).in_time_zone
          buildings = buildings.where('buildings.updated_at > ?', time);
        end

        buildings = buildings.order("buildings.updated_at ASC")
        buildings = buildings.page(building_params[:page]).per(per_page)
        images = Building.get_all_bldg_images(buildings)
        building_amenities = Building.get_amenities(buildings)

        output = buildings.map do |b|
          APIBuilding.new({
            building: b,
            images: images[b.building_id],
            amenities: building_amenities[b.building_id]
          })
        end
        #agents_arr = buildings.to_a
        #blob_cache_key = "api_v1_agentz"
        blob = #Rails.cache.fetch(blob_cache_key) do
          BuildingBlob.new({
            items: output,
            total_count: buildings.total_count,
            total_pages: buildings.total_pages,
            page: buildings.current_page
          })
        #end
        render json: blob
      end

      def show
        buildings = buildings_search({id: params[:id]})
        if buildings && buildings.length == 0
          render json: {}
        else
          images = Building.get_all_bldg_images(buildings)
          building_amenities = Building.get_amenities(buildings)
          render json: APIBuilding.new({
            building: buildings[0],
            images: images[buildings[0].building_id],
            amenities: building_amenities[buildings[0].building_id]
          })
        end
      end

    protected
      def building_params
        params.permit(:token, :pretty, :updated_at, :format, :per_page, :page, :changed_at)
      end

    end
  end
end

