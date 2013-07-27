require 'test/unit'
require 'SecureRandom'
 
class BackBeamTest < Test::Unit::TestCase
	def setup
		@secret = '7c8b1d69bcce60d81797f7dfaf17fd494a60f870f1c9d165f3e116713d272a2b1bfd16be787bd005'
		@key = 'ccf4c7c80f7e9ea984a849fc543a4d642d7af42f'
		@backbeam = BackBeam.new @secret, @key
  	end
	
  def test_get_all_entities
    assert @backbeam.get_entities('alchup').size > 0
  end

  def test_get_a_limited_group_of_entities
    assert @backbeam.get_entities('alchup', {:limit => 10}).size > 0
  end

  def test_throw_errors_from_backbeam
    assert_raise BackBeamException do
    	@backbeam.get_entities('entidad_chanante_que_no_existe')
    end
  end
end

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

	def get_entities(entity_name, parameters={})
		parameters.merge!({:time=>now, :nonce=>uuid, :key => @key})
		add_signature(parameters, "/data/#{entity_name}", GET)
		begin  
  			response = RestClient.get("http://api-dev-alchups.backbeamapps.com/data/#{entity_name}", {:params => parameters})
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