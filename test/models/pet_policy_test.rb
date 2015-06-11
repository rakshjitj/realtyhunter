require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @company = companies(:one)
    @pp = PetPolicy.all.each{|p| p.company_id = @company.id; p.save(); }
  end

  test 'policies_that_allow_cats only returns cat-friendly policies' do
  	policies = PetPolicy.policies_that_allow_cats(@company.id, true).map(&:id)
  	dogs_only_policy = pet_policies(:dogs_only)
  	cats_only_policy = pet_policies(:cats_only)
  	assert_not_includes policies, dogs_only_policy.id
  	assert_includes policies, cats_only_policy.id
  end
  
  test 'policies_that_allow_cats(false) returns cat-unfriendly policies' do
    policies = PetPolicy.policies_that_allow_cats(@company.id, false).map(&:id)
    dogs_only_policy = pet_policies(:dogs_only)
    cats_only_policy = pet_policies(:cats_only)
    assert_includes policies, dogs_only_policy.id
    assert_not_includes policies, cats_only_policy.id
  end

  test 'policies_that_allow_dogs only returns dog-friendly policies' do
  	policies = PetPolicy.policies_that_allow_dogs(@company.id, true).map(&:id)
  	dogs_only_policy = pet_policies(:dogs_only)
  	cats_only_policy = pet_policies(:cats_only)
  	assert_includes policies, dogs_only_policy.id
  	assert_not_includes policies, cats_only_policy.id
  end

  test 'policies_that_allow_dogs(false) only returns dog-unfriendly policies' do
    policies = PetPolicy.policies_that_allow_dogs(@company.id, false).map(&:id)
    dogs_only_policy = pet_policies(:dogs_only)
    cats_only_policy = pet_policies(:cats_only)
    assert_not_includes policies, dogs_only_policy.id
    assert_includes policies, cats_only_policy.id
  end

end