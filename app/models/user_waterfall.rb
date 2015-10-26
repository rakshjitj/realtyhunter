class UserWaterfall < ActiveRecord::Base
	belongs_to :parent_agent, :class_name => 'User', touch: true, dependent: :destroy
	belongs_to :child_agent, :class_name => 'User', touch: true, dependent: :destroy
	scope :unarchived, ->{where(archived: false)}

	# Agents earn different rates depending of if they are considered "active" or not.
	# Employees who still have their license parked with our company
  # (even if not actively working, on vacation, etc) earn a higher rate
  # than those who don't.
  # The first number in the array below represents what you earn if you are still active.
  # Second number is for when you're inactive.
	
	validates :parent_agent_id, presence: true
  # agents collect different commission rates depending on 
  # their seniority
  validates :agent_seniority_rate, presence: true, numericality: { only_integer: false }
	validates :level, presence: true, numericality: { only_integer: true }, 
		inclusion: { in: [1,2,3,4] }
	validates :rate, presence: true, numericality: { only_integer: false }

  
	def archive
    self.update(archived: true)
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  def self.get_rate(params)
  	if (!params[:parent_agent_id] || !params[:level] || params[:level].to_i < 1 || params[:level].to_i > 3)
  		return ""
  	end

  	rates = { 
			'senior': {
				'1': [5, 2],
				'2': [3.5, 1.25],
				'3': [2, 0.5]
			},
			'junior': {
				'1': [4, 2.5],
				'2': [2.5, 1.75],
				'3': [1, 1]
			}
		}

		parent = User.find(params[:parent_agent_id])
		idx = parent.archived ? 1 : 0
		rates[:senior][params[:level].to_sym][idx]
  end

  def self.search(params)
  	@running_list = UserWaterfall.unarchived
  		.joins('LEFT JOIN users AS parent_agents ON parent_agents.id = user_waterfalls.parent_agent_id
LEFT JOIN users AS child_agents ON child_agents.id = user_waterfalls.child_agent_id')
  		.select('user_waterfalls.id', 'rate', 'level', 'user_waterfalls.updated_at',
        'agent_seniority_rate',
  			'parent_agents.name as parent_agent_name', 
  			'child_agents.name as child_agent_name')

  	if !params[:parent_agent].blank?
      @running_list = 
      	@running_list.where('parent_agents.name ILIKE ?', "%#{params[:parent_agent]}%")
    end

    if !params[:parent_agent_id].blank?
      @running_list = 
      	@running_list.where('parent_agent_id = ?', params[:parent_agent_id])
    end

    if !params[:child_agent].blank?
      @running_list = 
      	@running_list.where('child_agents.name ILIKE ?', "%#{params[:child_agent]}%")
    end

    if !params[:level].blank? && ['1', '2', '3' '4'].include?(params[:level])
      @running_list = 
      	@running_list.where('level = ?', params[:level])
    end

  	@running_list
  end
	
end