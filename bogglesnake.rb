require 'pp'

# Describes a boggle-style matrix.
class Board

  attr_reader :rows, :cols, :board, :minword, :dict, :roots

  # Constructor, allow the user to specify the board size and minimum word size.
  def initialize rows = 3, cols = 3, minword = 3
    @rows = rows
    @cols = cols
    @board = Array.new(rows) { Array.new(cols, "A") }
    @minword = minword

    @dict = {}
    @roots = {}
  end

  # Load a dictionary word list.
  def initDictionary dictionaryFile
    boardLetters = {}
    for row in 0..(@rows - 1)
      for col in 0..(@cols - 1)
        boardLetters[@board[row][col]] = true
      end
    end

    File.open(dictionaryFile, 'r').each_line do |line|
      line.chomp!
      # Each word, if long enough (but not too long) is eligible.
      if (line.length >= @minword && line.length <= (@rows * @cols) && !line.index("'"))
        letter = line[0,1]

        # No need to include words that start with a letter not on the board.
        if !boardLetters[letter] then 
          next
        end

        # To make searching quicker, make a list of "roots" of the word. This will let us
        # determine if we are on a viable path to finding a word in the dictionary without 
        # traversing any further than absolutely necessary. For example, "apple" would 
        # have the roots "app" and "appl", so that we know we are on a legitimate path. 
        # Then, save the full word in a separate list for the actual matching.
        for i in @minword..line.length
          if i < line.length
            @roots[letter] = {} if @roots[letter].nil?
            @roots[letter][line[0,i]] = true
          else
            @dict[letter] = {} if @dict[letter].nil?
            @dict[letter][line] = true
          end
        end
      end
    end

    # Sorting provides a nominal speedup.
    @dict.each do |letter, vals|
      @dict[letter].sort
    end
  end

  # Setter
  def set coords, val
    @board[coords[0]][coords[1]] = val
  end

  # Getter
  def get coords
    @board[coords[0]][coords[1]]
  end

  # Creates a word from a path constructed of coordinates on the board.
  def word path
    out = "";
    path.each() do |coords|
      out += get [coords[0], coords[1]]
    end

    out
  end

  # Print the board.
  def to_s
    out = ''
    @board.each() do |row|
      out += row.join(',') + "\n"
    end
    out
  end

  # Print the board in HTML
  def to_html
    to_s.gsub(/\n/, "<br />")
  end

end

# This class locates the paths on the board and extracts words.
class Snake

  attr_reader :directions, :paths, :words

  # Constructor, defines the possible movements and instance vars.
  def initialize board
    @board = board
    @directions = [
      [1, 0], 
      [0, 1], 
      [1, 1], 
      [1, -1], 
      [-1, 0], 
      [0, -1], 
      [-1, -1],
      [-1, 1]
    ]
    @paths = []
    @words = []
  end

  # Searches the board for words.
  def search
    for row in 0..(@board.rows - 1)
      for col in 0..(@board.cols - 1)
        move row, col  
      end
    end
  end

  # Recursively moves from one point to as many legal points as possible.
  def move x, y, path = nil
    path = [[x,y]] if path.nil? 

    # Find legal moves.
    nextMoves = findMoves x, y, path

    nextMoves.each() do |coords|
      # Create a fork of the current path and see what the text string is.
      newPath = path.dup
      word = @board.word newPath
      letter = word[0,1]
      
      # Keep the word if it is long enough and is a legal word that hasn't already been added. 
      if (word.length >= @board.minword && @board.dict[letter] && @board.dict[letter][word] && !@words.include?(word)) then
        @words.push word
      end

      # There is at least one more legal move, so recurse if the word if it is too
      # short and exists in the roots dictionary.
      if (word.length < @board.minword || @board.roots[letter][word]) then
        newPath.push coords
        move coords[0], coords[1], newPath
      end
    end
  end

  # Returns all legal moves, filters out board points that have already been used.
  def findMoves x, y, path
    moves = []
    @directions.each() do |coords|
      newx = coords[0] + x
      newy = coords[1] + y
      if newx >= 0 && newy >= 0 && newx < @board.rows && newy < @board.cols
        val = @board.get [newx, newy]
        unless alreadyUsed? path, [newx, newy]
          moves.push [newx, newy]
        end
      end
    end

    moves
  end

  # Determines if this point has already been hit.
  def alreadyUsed? path, coords
    path.each() do |point| 
      return true if point[0] == coords[0] && point[1] == coords[1]    
    end
    false
  end

end

# Begin main

time = ''
start = Time.now

rows = 4
cols = 4

b = Board.new rows, cols
b.set [0,0],'a'
b.set [0,1],'r'
b.set [0,2],'i'
b.set [0,3],'g'
b.set [1,0],'t'
b.set [1,1],'s'
b.set [1,2],'t'
b.set [1,3],'f'
b.set [2,0],'e'
b.set [2,1],'l'
b.set [2,2],'e'
b.set [2,3],'g'
b.set [3,0],'t'
b.set [3,1],'f'
b.set [3,2],'r'
b.set [3,3],'n'

b.initDictionary "words"

inittime = Time.now - start
time += "dictionary loaded " + inittime.to_s + "\n"

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

out = ''
out += time + "\n\n"
out += b.to_s + "\n\n"
out += s.words.join("\n")

puts out
