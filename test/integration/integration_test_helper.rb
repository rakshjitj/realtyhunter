ActionController::Base.class_eval do
  def perform_action
    perform_action_without_rescue
  end
end

Dispatcher.class_eval do
  def self.failsafe_response(output, status, exception = nil)
    raise exception
  end
end