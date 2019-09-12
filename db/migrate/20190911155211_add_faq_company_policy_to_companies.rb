class AddFaqCompanyPolicyToCompanies < ActiveRecord::Migration[5.0]
  def change
  	add_column :companies, :faq_company_policy, :text
  end
end
