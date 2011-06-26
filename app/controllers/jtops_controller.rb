class JtopsController < ApplicationController
  def index
    if (!Jtop.last)
      render_error 404
      return
    end

    redirect_to jtop_path([2, params[:id].to_i].max) and return if params[:id]
    redirect_to jtop_path(Jtop.last)
  end

  def list
    render :inline => Ranking.count.to_s
  end

  def show
    @jtop = Jtop.get!(params[:id])
    params[:c] = 'rank' unless Ranking.properties[params[:c]] || ['clip'].include?(params[:c])
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
