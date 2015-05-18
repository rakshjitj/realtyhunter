class AgentType < ActiveRecord::Base
	before_save :sanitize_name

  def sanitize_name
    name.downcase.gsub!(' ', '_')
  end

  def self.sanitize_name(str)
    return str.downcase.gsub(' ', '_')
  end

  def display_name
  	name.titleize.gsub('_', ' ')
  end

end