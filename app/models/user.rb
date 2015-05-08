class User < ActiveRecord::Base
  rolify
	attr_accessor :remember_token, :activation_token, :reset_token
  before_create :create_activation_digest
  before_save :downcase_email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100}, 
						format: { with: VALID_EMAIL_REGEX }, 
            uniqueness: { case_sensitive: false }

  validates :fname, presence: true, length: {maximum: 50}
            #uniqueness: { case_sensitive: false }
  validates :lname, presence: true, length: {maximum: 50}
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

  def avatar_thumbnail_url
    S3_AVATAR_RESIZED_BUCKET['avatar_url']
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
      @running_list = @running_list.where('fname ILIKE ? or lname ILIKE ? or email ILIKE ?', "%#{term}%", "%#{term}%", "%#{term}%").all
    end

    @running_list.uniq
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
