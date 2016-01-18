class User < ActiveRecord::Base
  rolify
  default_scope { order("users.name ASC") }
  scope :unarchived, ->{where(archived: false)}

  has_and_belongs_to_many :roles, :join_table => :users_roles
  belongs_to :office
  belongs_to :company
  belongs_to :manager, :class_name => "User"
  belongs_to :employee_title
  has_many   :subordinates, :class_name => "User", :foreign_key => "manager_id"
  # A unit can have up to 2 assigned or "primary" agents
  # if you are assigned agent #1
  has_many :primary_units, class_name: 'Unit', :foreign_key => 'primary_agent_id'
  # if you are assigned agent #2
  has_many :primary2_units, class_name: 'Unit', :foreign_key => 'primary_agent2_id'
  # A unit can have only 1 listing agent
  has_many :listed_units,  class_name: 'Unit', :foreign_key => 'listing_agent_id'
  has_many :roommates, class_name: 'WufooRoommatesWebForm'
  has_many :roomsharing_applications
  has_many :user_waterfalls, class_name: 'UserWatefall', foreign_key: 'parent_agent_id'
  has_one :image, dependent: :destroy
  has_many :announcements
  has_many :deals

	before_create :create_activation_digest
  before_create :set_auth_token # for API
  before_save :sanitize_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100},
						format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  VALID_TELEPHONE_REGEX = /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/
  validates :mobile_phone_number, length: {maximum: 25}, allow_blank: true, #presence: true,
    format: { with: VALID_TELEPHONE_REGEX }

  validates :name, presence: true, length: {maximum: 50}
  has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
  validates :bio, length: {maximum: 2000}
  validates :company, presence: true
  validates :office, presence: true

  attr_accessor :remember_token, :activation_token, :reset_token, :approval_token, :agent_types, :batch

  def has_role?(role_name)
    self.roles.any? {|r| r.name == role_name.to_s}
  end

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # primary units only currently
  def residential_units(active_only=false)
    ids = []
    if active_only
      ids = self.primary_units.active.map(&:id) + self.primary2_units.active.map(&:id)
    else
      ids = self.primary_units.map(&:id) + self.primary2_units.active.map(&:id)
    end

    ResidentialListing.for_units(ids)
  end

  # primary units only currently
  def commercial_units(active_only=false)
    if active_only
      ids = self.primary_units.active.map(&:id) + self.primary2_units.active.map(&:id)
    else
      ids = self.primary_units.map(&:id) + self.primary2_units.active.map(&:id)
    end
    CommercialListing.for_units(ids)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_columns(remember_digest: User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    self.update(remember_digest: nil)
  end

  # Activates an account.
  def activate
    self.update(activated: true, activated_at: Time.zone.now)
  end

  # Marks an account as approved by an admin
  def approve
    self.update(approved: true, approved_at: Time.zone.now)
  end

  def unapprove
    self.update(approved: false, approved_at: nil)
  end

  def archive
    self.update(archived: true)
  end

  def self.find_unarchived(id)
    self.find_by!(id: id, archived: false)
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

  def assign_random_password
    self.password = SecureRandom.base64
  end

  # Sends password reset email.
  def send_added_by_admin_email(company)
    UserMailer.added_by_admin(company, self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # for use in search method below
  def self.get_images(list)
    user_ids = list.map(&:id)
    Image.where(user_id: user_ids).index_by(&:user_id)
  end

  def self.search(query_params, current_user)
    running_list = User
      .joins(:office, :employee_title)
      .where(company: current_user.company)
      .select('users.company_id', 'users.archived', 'users.id',
        'users.name', 'users.email', 'users.activated', 'users.approved', 'users.last_login_at',
        'employee_titles.name AS employee_title_name', 'employee_titles.id AS employee_title_id',
        'offices.name AS office_name', 'offices.id as office_id')

    if !query_params
      return running_list
    end

    if !query_params[:name_email].blank?
      query_string = query_params[:name_email]
      terms = query_string.split(" ")
      terms.each do |term|
        running_list = running_list.where('users.name ILIKE ? or users.email ILIKE ?', "%#{term}%", "%#{term}%").all
      end
    end

    if !query_params[:status].blank?
      if query_params[:status].downcase == 'active'
        running_list = running_list.where("users.archived = false")
      elsif query_params[:status].downcase == 'deleted'
        running_list = running_list.where("users.archived = true")
      end
    end

    running_list
  end

  # copies in new roles from
  # user.agent_types & user.employee_title
  def update_roles
    # clear out old roles
    #self.roles = [];

    # add a role representing your position in the company.
    # default to an agent if none otherwise specified
    if !self.employee_title
      self.employee_title = EmployeeTitle.agent
      self.save
    end

    # assign sensible defaults, if nothing is otherwise specified
    if !self.roles.length
      self.add_role :residential
      self.add_role :commercial
      self.add_role :sales
      self.add_role :agent
    end

    # (almost) everyone should always be able to see residential stuff
    # if self.employee_title != EmployeeTitle.external_vendor
    #   # note: this isn't really used anymore...
    #   # we decided that everyone should be able to view residential/commercial/sales listings
    #   self.add_role :residential
    #   self.add_role :commercial
    # end

    # if you're an agent, add in specific roles for the type of
    # agent that you are
    # if self.employee_title == EmployeeTitle.agent
    #   # cull out empty selections
    #   if self.agent_types
    #     self.agent_types = self.agent_types.select(&:present?)
    #   end
    #   # always make sure they at least have one specialty area selected
    #   if !self.agent_types || !self.agent_types.any?
    #     # note: this isn't really used anymore...
    #     # we decided that everyone should be able to view residential/commercial/sales listings
    #     self.add_role :residential
    #     self.add_role :commercial
    #   else
    #     # otherwise, note the specialities they indicated
    #     self.agent_types.each do |role|
    #       self.add_sanitized_role(role, true)
    #     end

    #   end
    # else
    #   self.add_sanitized_role(self.employee_title.name, false)
    # end
  end

  # def handles_residential?
  #   self.has_role? :residential
  # end

  # def handles_commercial?
  #   self.has_role? :commercial
  # end

  def handles_sales?
    self.has_role? :sales
  end

  def is_company_admin?
    self.has_role? :company_admin
  end

  def is_external_vendor?
    self.has_role? :external_vendor
  end

  def is_agent?
    employee_title == EmployeeTitle.agent
  end

  # does this user actually manage other agents?
  def is_manager?
    self.has_role? :manager
  end

  def is_photo_manager?
    self.has_role? :photo_manager
  end

  def is_listings_manager?
    has_role? :listings_manager
  end

  # Many roles can be considered 'managerial' from
  # a staffing point of view. Any employees that work
  # in operations should have permission to edit
  # listings or users. This is a catch-all function.
  def is_management?
    # self.roles.any? {|r| r.name == role_name.to_s}
    management_roles = [
      :super_admin,
      :company_admin,
      :operations,
      :data_entry,
      :broker,
      :associate_broker,
      :manager,
      :closing_manager]
    management_roles.each do |r|
      return true if self.has_role? r
    end

    false
  end

  def make_manager
    self.employee_title = EmployeeTitle.manager
    self.update_roles
  end

  def make_company_admin
    self.employee_title = EmployeeTitle.company_admin
    self.update_roles
  end

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

  def coworkers
    company.users.preload(:roles)
  end

  def self.get_all_agent_specialties(lists)
    user_ids = list.map(&:id)
  end

  # def self.get_images(list)
  #   user_ids = list.map(&:id)
  #   Image.where(user_id: user_ids).index_by(&:user_id)
  # end

  # keep a running list of our specialties so we
  # don't always have to recalculate
  def agent_specialties
    specialties = []

    if has_role? :residential
      specialties << 'Residential'
    end
    if has_role? :commercial
      specialties << 'Commercial'
    end
    if has_role? :sales
      specialties << 'Sales'
    end
    if has_role? :roomsharing
      specialties << 'Roomsharing'
    end

    specialties
  end

  # In order to approve another user, we must be:
  # - A company admin
  # - From the same company as the other user
  # - Higher in rank than the other user
  def can_approve(other_user)
    if other_user.employee_title_id && self.employee_title_id
      return self.is_company_admin? &&
    other_user.employee_title_id < self.employee_title_id
    else
      return self.is_company_admin? &&
    other_user.employee_title.id < self.employee_title.id
    end
  end

  # In order to kick another user from their team, we must be:
  # - at the same company
  # - either their direct manager or a company admin
  def can_kick(other_user)
    return other_user.manager &&
    (self.is_company_admin? ||
    (self == other_user.manager))
  end

  def kick
    self.manager = nil
    self.save
  end

  # In order to manage a team:
  # - The other user must be a manager
  # - We need to be a company admin or the manager in question
  # - We must both work for the same company
  def can_manage_team(other_user)
    return other_user.is_manager? &&
    (self.is_company_admin? || self == other_user)
  end

  # for use in our API
  def set_auth_token
    return if auth_token.present?
    self.auth_token = generate_auth_token
  end

  private

    def sanitize_email
      self.email = email.downcase
      email_md5 = Digest::MD5.hexdigest(self.email)
      self.public_url = "http://myspacenyc.com/agent/AGENT-#{email_md5}"
    end

    def create_activation_digest
      # Create the token and digest.
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
      self.approval_token  = User.new_token
      self.approval_digest = User.digest(approval_token)
    end

    # for use in our API
    def generate_auth_token
      loop do
        token = SecureRandom.hex
        found_user = User.find_by(auth_token: token)
        #break token unless found_user #self.class.exists?(auth_token: token)
        if !found_user
          return token
        end

      end
      #puts "done"
    end
end
