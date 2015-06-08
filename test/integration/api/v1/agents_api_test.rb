require 'test_helper'

class AgentsTest < ActionDispatch::IntegrationTest
	
	setup do 
		#host! 'api.example.com'
		@base_path = '/api/v1'

		@company = companies(:one)
		#@company.save
		@user = users(:michael)
		@user.company = @company
		@user.save
	end

	# test authentication
	def token_header(token)
		ActionController::HttpAuthentication::Token::encode_credentials(token)
	end

	test 'valid authentication with token' do 
		get "#{@base_path}/agents", {}, {'Authorization' => token_header(@user.auth_token) }
		assert_equal 200, response.status
		assert_equal Mime::JSON, response.content_type
	end

	test 'invalid authentication' do
		get "#{@base_path}/agents", {}, {'Authorization' => @user.auth_token + 'fake' }
		assert_equal 401, response.status
	end

	# test controller methods

	test 'returns list of all agents' do
		get "#{@base_path}/agents", {}, {'Authorization' => token_header(@user.auth_token) }
		assert response.success?
		agents = json(response.body)
		names = agents.collect{|u| u[:name] }
		assert_includes names, 'Michael Example'
	end

	test 'returns single agent' do
		user = users(:michael)
		get "#{@base_path}/agents/#{user.id}", {}, {'Authorization' => token_header(@user.auth_token) }
		assert response.success?
		agent = json(response.body)
		assert_equal user.name, agent[:name]
	end

	test 'returns agents in JSON' do
		get "#{@base_path}/agents", {}, {'Accept' => Mime::JSON, 'Authorization' => token_header(@user.auth_token)  }
		assert_equal 200, response.status
		assert_equal Mime::JSON, response.content_type
	end

	test 'requesting agents in XML should return JSON' do
		get "#{@base_path}/agents", {}, {'Accept' => Mime::XML, 'Authorization' => token_header(@user.auth_token)  }
		assert_equal 200, response.status
		assert_equal Mime::JSON, response.content_type
	end

	# fine grained tests - check business logic is correct

	test 'only users from our company are returned' do
		get "#{@base_path}/agents", {}, {'Authorization' => token_header(@user.auth_token) }
		assert response.success?
		agents = json(response.body)
		company_ids = agents.collect{|u| u[:company_id] }
		assert_includes company_ids, @user.company_id
	end

end