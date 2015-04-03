gem "minitest"

require 'minitest/autorun'
require 'webmock/minitest'
require 'wheniwork-api-ruby'
require 'json'

class WhenIWorkTest < Minitest::Test
	def setup
		stub_request(:post, "https://api.wheniwork.com/2/login")
			.to_return { |request|
				if request.headers.key?('W-Key') && request.headers['W-Key'] == 'iworksoharditsnotfunny' then
					next {:body => '{"login":{"id":5,"first_name":"Goldie","last_name":"Wilson","email":"goldiewilson@hillvalleygov.org","token":"ilovemyboss"},"users":[{"id":4364,"first_name":"Goldie","last_name":"Wilson","email":"goldiewilson@hillvalleycalifornia.gov","phone_number":"555-555-5555"}]}'}
				end

				next {:body => '{"error":"Please include a valid developer `key` for any unauthenticated requests.","code":1110}'}
			}
		stub_request(:get, "https://api.wheniwork.com/2/users")
			.to_return { |request|
				if request.headers.key?('W-Token') && request.headers['W-Token'] == 'realtoken' then
					next {:body => '{"users":[{"id":4364,"first_name":"Goldie","last_name":"Wilson","email":"goldiewilson@hillvalleycalifornia.gov","phone_number":"555-555-5555"},{"id":27384,"first_name":"Jennifer","last_name":"Parker","email":"jen.parker@example.com","phone_number":"555-555-5555"}]}'}
				end

				next {:body => '{"error":"User login required for this resource.","code":1000}'}
			}
		stub_request(:post, "https://api.wheniwork.com/2/users")
			.to_return { |request|
				if request.headers.key?('W-Token') && request.headers['W-Token'] == 'realtoken' then
					next {:body => '{"user":{"id":4364,"first_name":"Goldie","last_name":"Wilson","email":"goldiewilson@hillvalleycalifornia.gov","phone_number":"555-555-5555"}}'}
				end
				
				next {:body => '{"error":"User login required for this resource.","code":1000}'}
			}
	end

	def test_login_success
		res = WhenIWork.login('iworksoharditsnotfunny', 'test', 'test')

		assert res.key? 'login'
	end

	def test_login_failure
		res = WhenIWork.login('iworksosoftlyitsfunny', 'test', 'test')

		assert res.key? 'error'
	end

	def test_unauthenticated
		wiw = WhenIWork.new('faketoken')
		res = wiw.get('users')

		assert res.key? 'error'
	end
	
	def test_authenticated
		wiw = WhenIWork.new('realtoken')
		res = wiw.get('users')

		assert res.key? 'users'
	end

	def test_create_user
		wiw = WhenIWork.new('realtoken')

		user = {
			"email" => "user.mcuserton@example.com",
			"first_name" => "User",
			"last_name" => "McUserton",
			"phone_number" => "+15551234567"
		}

		res = wiw.create('users', user)

		assert res.key? 'user'
	end
end
