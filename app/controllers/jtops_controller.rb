class JtopsController < ApplicationController
  def index
    if (!Jtop.last)
      render_error 404
      return
    end

    redirect_to jtop_path(Jtop.last)
  end

  def list

  end

  def show
    @jtop = Jtop.get!(params[:id])
    unless Ranking.properties[params[:c]] || ['clip'].include?(params[:c])
      params[:c] = 'rank'
    end
    @rankings = rankings
  end

private
  def rankings
    if params[:c] == 'clip'
      if params[:d] == 'down'
        Ranking.sorted_by_clips(:desc).all(:jtop_id => @jtop.id)
      else
        Ranking.sorted_by_clips.all(:jtop_id => @jtop.id)
      end
    else
      @jtop.rankings(:order => sort_order)
    end
  end
end
