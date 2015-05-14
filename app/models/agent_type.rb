class AgentType < ActiveRecord::Base
	before_save :sanitize_name

  def sanitize_name
    name.downcase.gsub!(' ', '_')
  end

end