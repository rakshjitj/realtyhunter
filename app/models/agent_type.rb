class AgentType < ActiveRecord::Base
	before_save :sanitize_name
  default_scope { order("name ASC") }
  
  def sanitize_name
    name.downcase.gsub!(' ', '_')
  end

  def self.sanitize_name(str)
    return str.downcase.gsub(' ', '_')
  end

  def display_name
  	name.titleize.gsub('_', ' ')
  end

  def self.all_cached
    Rails.cache.fetch('agent_types') {
      AgentType.all
    }
  end
end