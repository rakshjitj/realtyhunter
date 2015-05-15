class User < ActiveRecord::Base
  rolify
  belongs_to :office
  belongs_to :company
  belongs_to :manager, :class_name => "User"
  belongs_to :employee_title
  has_many :subordinates, :class_name => "User", :foreign_key => "manager_id"
  attachment :avatar #, extension: ["jpg", "jpeg", "png", "gif"]

	attr_accessor :remember_token, :activation_token, :reset_token, :approval_token, :agent_types
  before_create :create_activation_digest
  before_save :downcase_email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100}, 
						format: { with: VALID_EMAIL_REGEX }, 
            uniqueness: { case_sensitive: false }

  validates :name, presence: true, length: {maximum: 50}
            #uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	# Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Marks an account as approved by an admin
  def approve
    update_columns(approved: true, approved_at: Time.zone.now)
  end

  def unapprove
    update_columns(approved: false, approved_at: nil)
  end

  def fname
    self.name.split(' ')[0]
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # sends the company admin a notification, asking to 
  # approve this user
  def send_company_approval_email
    UserMailer.account_approval_needed(self, self.company).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Sends account_created_by_admin email
  #def send_account_created_by_admin
  #  UserMailer.account_created_by_admin(self).deliver_now
  #end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def self.search(query_string)
    @running_list = User.all

    if !query_string
      return @running_list
    end
    
    @terms = query_string.split(" ")
    @terms.each do |term|
      #puts "**** #{term} ****\n"
      term = "%#{term}%"
      @running_list = @running_list.where('name ILIKE ? or email ILIKE ?', "%#{term}%", "%#{term}%").all
    end

    @running_list.uniq
  end

  #def avatar_thumbnail_url
  #  return S3_AVATAR_THUMBNAIL_BUCKET.objects[self.avatar_key].url_for(:read).to_s
  #end

  #def avatar_url
  #  return S3_AVATAR_BUCKET.url + self.avatar_key
  #end

  # copies in new roles from 
  # user.agent_types & user.employee_title
  
  def update_roles
    # clear out old roles
    self.roles = [];
    # add a role representing your position in the company.
    # default to an agent if none otherwise specified
    if !self.employee_title
      self.employee_title = EmployeeTitle.agent
      self.save
    end
    
    # if you're an agent, add in specific roles for the type of
    # agent that you are
    if self.employee_title == EmployeeTitle.agent
      # cull out empty selections
      if self.agent_types
        self.agent_types = self.agent_types.select(&:present?)
      end
      # always make sure they at least have one specialty area selected
      if !self.agent_types || !self.agent_types.any?
        self.add_role :residential
      else
        # otherwise, note the specialities they indicated
        self.agent_types.each do |role|
          self.add_sanitized_role(role, true)
        end

      end
    else 
      self.add_sanitized_role(self.employee_title.name, false)
    end
  end

  def is_manager?
    self.has_role? :manager
  end

  def is_company_admin?
    self.has_role? :company_admin
  end

  def is_agent?
    AgentType.all.each do |at|
      return true if self.has_role? at.name
    end
    return false
  end

  def make_manager
    self.employee_title = EmployeeTitle.manager
    self.update_roles
  end

  #def remove_manager
  #  subordinates.clear
  #  self.remove_role :manager
  #end

  def add_subordinate(subord)
    if self.has_role? :manager
      subord.manager = self
      subord.save
      #puts "#{subord.manager.name} "
      #puts "#{subord.manager.subordinates.length} \n\n"
    else
      raise 'Tried to add subordinate without being manager first'  
    end
  end

  def remove_subordinate(subord)
    if self.has_role? :manager
      subord.manager = nil
    else
      raise 'Tried to remove subordinate without being manager first'  
    end
  end

  def is_management?
    if (has_role? :company_admin) || 
      (has_role? :operations) ||
      (has_role? :broker) || 
      (has_role? :associate_broker) ||
      (has_role? :manager)
      true
    else 
      false
    end    
  end

  def coworkers
    @coworkers = Array.new(self.company.users)
    @coworkers.delete(self)
    @coworkers
  end

  # this is just so we can define the busines logic in a centralized place.
  # this is a non-functional user
  def self.define_roles
    @user = User.create({
      email: 'topsecret@admin.com', 
      name: "Roles Definition",
      password:"test123" });
    # Inactive Agent:
    @user.add_role :inactive_agent
    # Licensed Agent:
    @user.add_role :residential
    @user.add_role :commercial
    @user.add_role :sales
    @user.add_role :roomsharing
    @user.add_role :associate_broker
    @user.add_role :broker
    # Executive Agent:
    @user.add_role :manager
    @user.add_role :closing_manager
    @user.add_role :marketing
    @user.add_role :operations
    @user.add_role :company_admin
    # Not for nestio:
    @user.add_role :super_admin

    @user.delete
  end

  def agent_specialties
    @specialities = []
    AgentType.all.each do |a|
      if self.has_role? a.name
        @specialities << a.name.titleize
      end
    end
    @specialities
  end

  def agent_specialties_as_indicies
    @specialities = []
    AgentType.all.each do |a|
      if self.has_role? a.name
        @specialities << a.id
      end
    end

    @specialities
  end

  def add_sanitized_role(unsan_role_name, is_agent_type)
    # input has not been sanitized. let's translate it into our 
    # naming scheme
    
    # don't allow roles that are not approved by us
    @real_role_name = nil
    if is_agent_type
      @name = unsan_role_name.downcase.gsub(' ', '_')
      @real_role = AgentType.where(name: @name).first
      @real_role_name = @real_role.name
    else
      @real_role = EmployeeTitle.where(name: unsan_role_name).first
      @real_role_name = @real_role.name.downcase.gsub(' ', '_')  
    end

    if @real_role_name
      self.add_role @real_role_name
    else
      raise "No role found by that name [#{@unsan_role_name}]"
    end
  end

  # In order to approve another user, we must be:
  # - A company admin
  # - From the same company as the other user
  # - Higher in rank than the other user
  def can_approve(other_user)
    return self.is_company_admin? && self.company == other_user.company &&
    other_user.employee_title.id < self.employee_title.id
  end

  # In order to kick another user from their team, we must be:
  # - at the same company
  # - either their direct manager or a company admin
  def can_kick(other_user)
    return (self.company == other_user.company) &&
    ((self.is_company_admin? && other_user.manager) ||
    (self == other_user.manager))
  end

  # In order to manage a team:
  # - The other user must be a manager
  # - We need to be a company admin
  # - We must both work for the same company
  def can_manage_team(other_user)
    return other_user.is_manager? && 
    self.is_company_admin? &&
    self.company == other_user.company
  end

  private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digest
      # Create the token and digest.
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
      self.approval_token  = User.new_token
      self.approval_digest = User.digest(approval_token)
    end



end
