class ArtistsController < ApplicationController
  def index
    params[:c] ||= 'name'

    @artists = params[:c] != 'clip_count' ? Artist.all(:order => sort_order) : Artist.all

    direction = (params[:d] == 'up' ? 1 : -1)
    @artists = @artists.sort_by { |a| direction * a.clip_count} if params[:c] == 'clip_count'
  end

  def show
    params[:c] ||= 'title'

    @artist = Artist.find(params[:id])
    @clips = @artist.clips(:order => sort_order)
  end
end
