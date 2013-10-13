require_relative 'bogglesnake.rb'
require 'sinatra'
require 'haml'
require 'json'

# Sinatra conf.
set :bind, '0.0.0.0'
set :port, '4000'

# Route.
get '/submit' do

  rows = 5
  cols = 5

  b = Board.new rows, cols

  words = []

  if !params['values'].nil?
    params['values'].each do |row, cols|
      col = 0;
      cols.each do |value|
        b.set [row.to_i, col], value
        col += 1
      end
    end

    b.initDictionary "words"

    s = Snake.new b
    s.search

    s.words.to_json
  end

end

# Route.
get '/' do
  time = ''
  start = Time.now

  rows = 5
  cols = 5

  b = Board.new rows, cols

  pp params
  
  if !params['input'].nil?
    params['input'].each do |row, cols|
      cols.each do |col, value|
        b.set [row.to_i, col.to_i], value
      end
    end
  else
    b.set [0,0],'a'
    b.set [0,1],'b'
    b.set [0,2],'r'
    b.set [0,3],'a'
    b.set [0,4],'b'
    b.set [1,0],'b'
    b.set [1,1],'s'
    b.set [1,2],'e'
    b.set [1,3],'w'
    b.set [1,4],'d'
    b.set [2,0],'e'
    b.set [2,1],'l'
    b.set [2,2],'e'
    b.set [2,3],'p'
    b.set [2,4],'g'
    b.set [3,0],'b'
    b.set [3,1],'g'
    b.set [3,2],'t'
    b.set [3,3],'s'
    b.set [3,4],'g'
    b.set [4,0],'a'
    b.set [4,1],'m'
    b.set [4,2],'k'
    b.set [4,3],'s'
    b.set [4,4],'u'
  end
  
  inittime = Time.now - start
  time += "dictionary loaded " + inittime.to_s + "\n"
  b.initDictionary "words"
  
  s = Snake.new b
  s.search
  
  searchtime = Time.now - start
  time += "search completed " + searchtime.to_s + "\n"
  
  # Debugging.
  #pp s.words
  #pp b.roots
  #pp b.dict
  #pp st
  #pp s
  #pp b.to_html
  
  haml :index, :locals => {:rows => b.rows, :cols => b.cols, :board => b.board, :words => s.words}
end
