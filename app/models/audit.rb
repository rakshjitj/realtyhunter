# models/audit.rb
class Audit < Audited::Audit
  def self.default_scope
    includes(:user)
  end

  def self.default_sort
    descending
  end
end
