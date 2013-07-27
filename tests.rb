require 'test/unit'
require 'SecureRandom'
require './backbeam'
 
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

  def test_get_one_entity
  	id = @backbeam.get_entities('alchup', {:limit => 1}).keys.first
    assert @backbeam.get_entity('alchup', id)
  end
end