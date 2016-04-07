require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class PetPolicyTest < ActiveSupport::TestCase

  def setup
    # trigger the after_save callbacks so pet policies get created
    @company = create(:company)
    # pet policies should have been defined by now...
    @pp_dogs = PetPolicy.find_by(name: 'dogs only');
    @pp_cats = PetPolicy.find_by(name: 'cats only');
  end

  test 'names are downcased' do
    assert_equal "dogs only", @pp_dogs.name
  end

  test 'policies_that_allow_cats only returns cat-friendly policies' do
  	policies = PetPolicy.policies_that_allow_cats(@company.id, true).ids
  	assert_not_includes policies, @pp_dogs.id
  	assert_includes policies, @pp_cats.id
  end

  test 'policies_that_allow_cats(false) returns cat-unfriendly policies' do
    policies = PetPolicy.policies_that_allow_cats(@company.id, false).ids
    assert_includes policies, @pp_dogs.id
    assert_not_includes policies, @pp_cats.id
  end

  test 'policies_that_allow_dogs only returns dog-friendly policies' do
  	policies = PetPolicy.policies_that_allow_dogs(@company.id, true).ids
  	assert_includes policies, @pp_dogs.id
  	assert_not_includes policies, @pp_cats.id
  end

  test 'policies_that_allow_dogs(false) only returns dog-unfriendly policies' do
    policies = PetPolicy.policies_that_allow_dogs(@company.id, false).ids
    assert_not_includes policies, @pp_dogs.id
    assert_includes policies, @pp_cats.id
  end

end
