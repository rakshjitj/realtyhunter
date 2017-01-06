module SessionsHelper
	# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    session[:expires_at] = Time.current + 24.hours
    user.update_columns(last_login_at: Time.zone.now)
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      #puts "found from session"
      @current_user ||= User.where(id: user_id).first
    elsif (user_id = cookies.signed[:user_id])
      #puts "found from cookies"
      user = User.where(id: user_id).first
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    # session.delete(:user_id)
    reset_session
    @current_user = nil
  end

# Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

end
