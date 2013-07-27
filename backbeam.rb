require 'json'
require 'rest_client'
require 'openssl'
require 'base64'

class BackBeam
	GET = 'GET'
	POST = 'POST'

	def initialize(secret, key)
	    @secret = secret
	    @key = key
	end

	def get_entity(entity_name, id, parameters={})
		objects = make_request(parameters, "/data/#{entity_name}/#{id}", GET)
		objects.first
	end

	def get_entities(entity_name, parameters={})
		objects = make_request(parameters, "/data/#{entity_name}", GET)
	end

	def make_request(parameters, path, method)
		parameters.merge!({:time=>now, :nonce=>uuid, :key => @key})
		add_signature(parameters, path, GET)
		begin  
  			response = RestClient.get("http://api-dev-alchups.backbeamapps.com#{path}", {:params => parameters})
  			json = JSON.parse response
			json['objects']
		rescue Exception => e
		  raise BackBeamException.new(e.response), e.message
		end  
	end


	private
	def add_signature(parameters, path, method)
		signature_base = ""
		params_for_signtaure = {:path => path, :method => method}
		params_for_signtaure.merge! parameters
		params_for_signtaure.sort.map do |key,value|
  			signature_base += "#{key}=#{value}&"
		end
		signature_base.chomp!("&")
		parameters[:signature] = Base64.encode64(OpenSSL::HMAC.digest('sha1', @secret, signature_base)).strip()
	end

	def uuid
		nonce = SecureRandom.uuid
	end

	def now
		Time.now.to_i*1000
	end
end

class BackBeamException < StandardError
	attr_accessor :status
	def initialize(response=nil)
		json = JSON.parse response
		@status = json['status']
	end
end