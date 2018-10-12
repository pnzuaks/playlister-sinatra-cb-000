class SongsController < ApplicationController

  get '/songs' do
    @songs = Song.all
    erb :'/songs/index'
  end

  get '/songs/new' do
    @genres = Genre.all
    erb :'/songs/new'
  end

  get '/songs/:slug' do
    @song = Song.find_by_slug(params[:slug])
    erb :'songs/show'
  end

  post '/songs/new' do
    response = CreateSongCommand.new(params).execute()
    if (!response.error)
      flash[:message] = "Successfully created song."
      redirect "/songs/#{response.value.slug}"
      # erb :'/songs/show', locals: {message: message}
    end
    # if response.error
    #   message = "Unable to create song"
    # else
    #   message = "Successfully created song"
    # end
    #
    # erb :'/songs/show', locals: {message: message}
  end

  get '/songs/:slug/edit' do
    @song = Song.find_by_slug(params[:slug])
    erb :'/songs/edit'
  end

  patch '/songs/:slug' do
    @song = Song.find_by_slug(params[:slug])
    @song.update(params[:song])
    @song.artist = Artist.find_or_create_by(name: params[:artist][:name])

    @song.genre_ids = params[:genres]
    @song.save


    # @song.genres.clear
    # @song.genres = params[:song][:genres]
    # @song.save
    #
    # genres.each do |genre|
    #   @song.genres << Genre.find(genre)
    # end
    #
    # @song.save
    flash[:message] = "Successfully updated song."
    redirect to "songs/#{song.slug}"
    # erb :'/songs/show', locals: {message: "Successfully updated song."}
  end
end

class CreateSongCommand
  def initialize(params)
    @song_name = params["song"]["name"]
    @artist_name = params["song"]["artist"]
    @genre = params["song"]["genres"]

    if @song_name.nil?
      raise "Expected name to not be empty"
    end

    if @artist_name.nil?
      raise "Expected artist name to not be empty"
    end

    if @genre.nil?
      raise "Expected genre to not be empty"
    end
  end

  def execute
    begin
      @song = Song.create(:name => @song_name)
      @song.artist = Artist.find_or_create_by(:name => @artist_name)
      @song.genre_ids = @genre
      @song.save
      return CommandResponse.new(@song)
    rescue
      return CommandResponse.new(nil, "Unable to create song")
    end
  end
end

class CommandResponse
  attr_accessor :value, :error
  def initialize(value, error = false)
    @value = value
    @error = false
  end
end
