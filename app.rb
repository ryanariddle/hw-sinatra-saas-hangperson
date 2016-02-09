require 'sinatra/base'
require 'sinatra/flash'
require './lib/hangperson_game.rb'

class HangpersonApp < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  
  before do
    @game = session[:game] || HangpersonGame.new('')
  end
  
  after do
    session[:game] = @game
  end
  
  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
  get '/' do
    redirect '/new'
  end
  
  get '/new' do
    erb :new
  end
  
  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || HangpersonGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = HangpersonGame.new(word)
    redirect '/show'
  end
  
  # Use existing methods in HangpersonGame to process a guess.
  # If a guess is repeated, set flash[:message] to "You have already used that letter."
  # If a guess is invalid, set flash[:message] to "Invalid guess."
  post '/guess' do
    letter = params[:guess].to_s[0]
    ### YOUR CODE HERE ###
    begin
      r = @game.guess(letter)
    rescue ArgumentError => e
      flash[:notice] = e.message
    end
    if not r
      if @wrong_guesses.include? letter or @guesses.include? letter
        flash[:message] = "You have already used that letter."
      else
        flash[:message] = "Invalid guess."
      end
    end
    redirect '/show'
  end
  
  # Everytime a guess is made, we should eventually end up at this route.
  # Use existing methods in HangpersonGame to check if player has
  # won, lost, or neither, and take the appropriate action.
  # Notice that the show.erb template expects to use the instance variables
  # wrong_guesses and word_with_guesses from @game.
  get '/show' do
    ### YOUR CODE HERE ###
    if @game.check_win_or_lose == :win
      redirect 'win'
    elsif @game.check_win_or_lose == :lose
      redirect 'lose'
    else
      erb :show
    end
  end
  
  get '/win' do
    ### YOUR CODE HERE ###
    if @game.check_win_or_lose != :win
      redirect '/show'
    end
    erb :win # You may change/remove this line
  end
  
  get '/lose' do
    ### YOUR CODE HERE ###
    if @game.check_win_or_lose != :lose
      redirect '/show'
    end
    erb :lose # You may change/remove this line
  end
  
end

class HangpersonGame
  attr_reader :word, :guesses, :wrong_guesses
  
  def initialize(w)
    @word=w
    @guesses=""
    @wrong_guesses=""
  end
  
  def word
    return @word
  end
  
  def guesses
    return @guesses
  end
  
  def wrong_guesses
    return @wrong_guesses
  end
  
  def guess(g)
    if g.nil? or g.empty? or not g =~ /[A-Za-z]/
      raise ArgumentError.new("ArgumentError")
    end
    g = g.downcase
    if @word.include? g
      if @guesses.include? g
        return false
      else
       @guesses = @guesses + g
      end
    else
      if @wrong_guesses.include? g
        return false
      else
        @wrong_guesses = @wrong_guesses + g
      end
    end
    return true
  end
  
  def word_with_guesses
    r = ""
    @word.split("").each do |i|
      if @guesses.include? i
        r << i
      else
        r << "-"
      end
    end
    return r
  end
  
  def check_win_or_lose
    if @wrong_guesses.length >= 7
      return :lose
    elsif @guesses.length == word.length
      return :win
    else
      return :play
    end
  end

end