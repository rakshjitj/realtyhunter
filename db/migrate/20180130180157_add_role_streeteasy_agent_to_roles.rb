class AddRoleStreeteasyAgentToRoles < ActiveRecord::Migration[5.0]
  def change
  	r = Role.find_or_create_by(name: "streeteasy_agent")
    r.save
  end
end
