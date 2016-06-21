module API
  module V1

    class BuildingsController < ApiController
      def index
        # pagination
        per_page = 50

        # warning: must return buildings.id unmapped. do not change that line!
        @buildings = Building.unarchived
          .joins(:company)
          .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
          .where(company: @user.company)
          .select('buildings.id', 'buildings.id as building_id',
          'buildings.administrative_area_level_2_short',
          'buildings.administrative_area_level_1_short as b_administrative_area_level_1_short',
          'buildings.sublocality as b_sublocality',
          'buildings.street_number as b_street_number',
          'buildings.route as b_route',
          'buildings.postal_code as b_postal_code',
          'buildings.lat as b_lat',
          'buildings.lng as b_lng',
          'buildings.llc_name',
          'buildings.updated_at',
          'neighborhoods.name as neighborhood_name',
          'neighborhoods.borough as neighborhood_borough')

        # updated_at
        if building_params[:changed_at] && !building_params[:changed_at].empty?
          time = Time.parse(building_params[:changed_at]).in_time_zone
          @buildings = @buildings.where('buildings.updated_at > ?', time);
        end

        @buildings = @buildings.order("buildings.updated_at ASC")
        @buildings = @buildings.page(building_params[:page]).per(per_page)
        @images = Building.get_all_bldg_images(@buildings)

        #agents_arr = @buildings.to_a
        #blob_cache_key = "api_v1_agentz"
        blob = #Rails.cache.fetch(blob_cache_key) do
          BuildingBlob.new({
            items: @buildings,
          })
        #end
        render json: blob
      end

      def show
        @building = Building.find(params[:id])
        render json: @building
      end

    protected
      def building_params
        params.permit(:token, :pretty, :updated_at, :format, :per_page, :page, :changed_at)
      end

    end
  end
end

