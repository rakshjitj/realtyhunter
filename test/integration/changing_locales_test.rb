require 'test_helper'

class ChangingLocalesTset < ActionDispatch::IntegrationTest
	
	setup { host! 'api.example.com' }

	test 'returns agents in english' do
		user = users(:michael)
		get "/agents/#{user.id}", {}, {'Accept-Language' => 'en', 'Accept' => Mime::JSON }
		assert_equal 200, response.status
		assert_equal Mime::JSON, response.content_type
		agent = json(response.body)
		assert_equal user.name, agent[:name]
	end

	test 'returns agents in brazilian portuguese' do
		user = users(:michael)
		get "/agents/#{user.id}", {}, {'Accept-Language' => 'pt-BR', 'Accept' => Mime::JSON }
		assert_equal 200, response.status
		assert_equal Mime::JSON, response.content_type
		agent = json(response.body)
		assert_equal user.name, agent[:name]
	end

end