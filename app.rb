require 'sinatra'
require './backbeam'

get '/' do
  backbeam = BackBeam.new '7c8b1d69bcce60d81797f7dfaf17fd494a60f870f1c9d165f3e116713d272a2b1bfd16be787bd005', 'ccf4c7c80f7e9ea984a849fc543a4d642d7af42f'
  erb :index, :locals => { :alchups => backbeam.get_entities('alchup') }
end