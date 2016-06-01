module API
  module V1

    class LandlordsController < ApiController
      def index
        # pagination
        per_page = 50

        @landlords = Landlord.unarchived
          .joins(:company)
          .where(company: @user.company)
          .select('landlords.code', 'landlords.name', 'landlords.contact_name',
          'landlords.office_phone', 'landlords.mobile', 'landlords.fax',
          'landlords.email', 'landlords.website',
          'landlords.administrative_area_level_1_short as l_administrative_area_level_1_short',
          'landlords.sublocality as l_sublocality',
          'landlords.street_number as l_street_number', 'landlords.route as l_route',
          'landlords.postal_code as l_postal_code',
          'landlords.lat as l_lat',
          'landlords.lng as l_lng',
          'landlords.listing_agent_id', 'landlords.listing_agent_percentage',
          'landlords.has_fee as l_has_fee',
          'landlords.op_fee_percentage as l_op_fee_percentage',
          'landlords.tp_fee_percentage as l_tp_fee_percentage')

        # updated_at
        if landlord_params[:changed_at] && !landlord_params[:changed_at].empty?
          time = Time.parse(landlord_params[:changed_at]).in_time_zone
          @landlords = @landlords.where('landlords.updated_at > ?', time);
        end

        @landlords = @landlords.order("landlords.updated_at ASC")
        @landlords = @landlords.page(landlord_params[:page]).per(per_page)

        blob = LandlordBlob.new({landlords: @landlords})
        render json: blob
      end

      def show
        @landlord = Landlord.find(params[:id])
        render json: @landlord
      end

    protected
      def landlord_params
        params.permit(:token, :pretty, :updated_at, :format, :per_page, :page, :changed_at)
      end

    end
  end
end

