require 'spec_helper'

describe "CreateSongCommand" do
    let(:route_params) { { "song"=>{"name"=>"That One with the Guitar", "artist"=>"Person with a Face", "genres"=>["1"]}} }
    it "can be initialized" do
      cmd = CreateSongCommand.new(route_params)
      expect(cmd).to be_an_instance_of(CreateSongCommand)
    end

    it "Creates a song with an artist" do
      @genre = Genre.create(:name => "Electro Derp")
      cmd = CreateSongCommand.new(route_params)

      response = cmd.execute()

      @song = Song.find_by(:Name => route_params["song"]["name"])
      expect(@song).to be_an_instance_of(Song)
      expect(@song.name).to eq(route_params["song"]["name"])
      expect(response.error).to eq(false)
      expect(response.value).to be_an_instance_of(Song)
    end

    it "Ensures no duplicate artists are created" do
      artist_count_before = Artist.all.count
      expect(artist_count_before).to eq(0)
      @genre = Genre.create(:name => "Electro Derp")
      cmd = CreateSongCommand.new(route_params)
      cmd.execute()
      artist_count_after_1 = Artist.all.count
      expect(artist_count_after_1).to eq(1)
      cmd.execute()
      artist_count_after_2 = Artist.all.count
      expect(artist_count_after_2).to eq(artist_count_after_1)
    end
end
