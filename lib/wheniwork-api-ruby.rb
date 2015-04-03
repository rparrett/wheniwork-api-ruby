require 'json'

class WhenIWork
	attr_accessor :api_token, :api_endpoint, :api_headers, :verify_ssl

	VERSION = '0.1'
	
	##
	# Creates a new WhenIWork API client
	#
	# @param [String] :api_token Your WhenIWork API token. Obtained with WhenIWork.login

	def initialize(api_token)
		@api_endpoint = 'https://api.wheniwork.com/2' if @api_endpoint.nil?
		@api_headers = [] if @api_headers.nil?
		@verify_ssl = false if @verify_ssl.nil?

		@api_token = api_token
	end

	##
	# Get an object or list
	#
	# @param [String] :endpoint The API endpoint to call, e.g. 'users', 'users/2'
	# @param [Hash] :params A Hash of arguments to pass to the endpoint
	# @param [Hash] :headers A Hash of custom headers to be passed
	# @return [Hash] Decoded JSON response

	def get(endpoint, params = {}, headers = {})
		make_request(endpoint, :get, params, headers)
	end
	
	##
	# Post to an endpoint. Can be used to create an object.
	#
	# @param [String] :endpoint The API endpoint to call, e.g. 'shifts/publish'
	# @param [Hash] :params A Hash of data used to create the object
	# @param [Hash] :headers A Hash of custom headers to be passed
	# @return [Hash] Decoded JSON response

	def post(endpoint, params = {}, headers = {})
		make_request(endpoint, :post, params, headers)
	end
	alias create post
	
	##
	# Update an object. Must include the ID.
	#
	# @param [String] :endpoint The API endpoint to call, e.g. 'users/1'
	# @param [Hash] :params A Hash data used to create the object
	# @param [Hash] :headers A Hash of custom headers to be passed
	# @return [Hash] Decoded JSON response

	def put(endpoint, params = {}, headers = {})
		make_request(endpoint, :put, params, headers)
	end
	alias update put

	##
	# Delete an object. Must include the ID.
	#
	# @param [String] :endpoint The API endpoint to call, e.g. 'users/1'
	# @param [Hash] :params A Hash of arguments to pass to the endpoint
	# @param [Hash] :headers A Hash of custom headers to be passed
	# @return [Hash] Decoded JSON response.

	def delete(endpoint, params = {}, headers = {})
		make_request(endpoint, :delete, params, headers)
	end

	##
	# Builds and performs the request to the WhenIWork API
	#
	# @param [String] :endpoint The API endpoint to be called
	# @param [Symbol] :method The HTTP method to use
	# @param [Hash] :params A Hash of parameters to be passed as a query string or form data
	# @param [Hash] :headers A Hash of custom headers to be passed

	def make_request(endpoint, method, params = [], headers = {})
		uri = URI.parse(@api_endpoint + '/' + endpoint)

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		req = case
		when method == :get
			Net::HTTP::Get.new(uri.path)
		when method == :post
			Net::HTTP::Post.new(uri.path)
		when method == :create
			Net::HTTP::Create.new(uri.path)
		when method == :update
			Net::HTTP::Update.new(uri.path)
		when method == :delete
			Net::HTTP::Delete.new(uri.path)
		else
			raise 'Unsupported HTTP method'
		end

		if [:post, :put, :patch].include?(:method) then
			req.set_form_data(params)
		else
			uri.query = URI.encode_www_form(params)
		end

		headers.each { |k, v|
			req[k] = v
		}

		req['W-Token'] = @api_token
		req['User-Agent'] = 'WhenIWork-Ruby/' + VERSION
		
		res = http.request(req)
		
		return JSON.parse(res.body)
	end

	##
	# Use developer key and credentials to obtain an API token
	#
	# @param [String] :key Your Developer API key
	# @param [String] :email Email address of user logging in
	# @param [String] :password Password of user logging in
	# @return [Hash] Decoded JSON response.

	def self.login(key, email, password)
		params = {
			"username" => email,
			"password" => password
		}

		headers = {
			"W-Key" => key
		}

		wiw = WhenIWork.new(nil)

		res = wiw.post('login', params, headers)
	end
end
