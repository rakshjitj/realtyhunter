class AddsRentedByAgentToDeals < ActiveRecord::Migration
  def change
    add_reference :deals, :rented_by_agent, index: true
  end
end
