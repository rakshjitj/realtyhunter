class User < ActiveRecord::Base
  rolify
  belongs_to :office
  belongs_to :company
  belongs_to :manager, :class_name => "User"
  has_many :subordinates, :class_name => "User", :foreign_key => "manager_id"

  attachment :avatar #, extension: ["jpg", "jpeg", "png", "gif"]
	attr_accessor :remember_token, :activation_token, :reset_token
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

  def fname
    self.name.split(' ')[0]
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
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

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  #def avatar_thumbnail_url
  #  S3_AVATAR_RESIZED_BUCKET['avatar_url']
  #end

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

  def is_manager?
    self.has_role? :manager
  end

  def is_company_admin?
    self.has_role? :company_admin
  end

  def make_manager
    self.add_role :manager
  end

  def remove_manager
    subordinates.clear
    self.remove_role :manager
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

  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digest
      # Create the token and digest.
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
