class ClipsController < ApplicationController
  def chart
    render :inline => "Please choose at least 1 and at most 20 clips.", status => 400 and return unless params[:clip_ids] && (1..20).include?(params[:clip_ids].count)

    @rankings = []
    min, max = Ranking.all(:clip_id => params[:clip_ids]).aggregate(:jtop_id.min, :jtop_id.max)
    jtop_id = params[:jtop_id] ? params[:jtop_id].to_i : max
    x_min = [min, jtop_id-25].max
    x_max = [max, x_min+50].min

    rankings = Ranking.all(:clip_id => params[:clip_ids], :order => :jtop_id,  :jtop_id.gte => min, :jtop_id.lte => max)
    y_min, y_max = rankings.aggregate(:rank.min, :rank.max)
    clips = rankings.clips
    artists = rankings.clips.artists
    rankings_by_clip_ids = rankings.group_by {|r|r.clip_id}
    rankings_by_clip_ids.each { |clip_id, rankings|
      data = Array.new(max-min+1)
      rankings.each {|r| data[r.jtop_id-min] = r.rank }

      # Hack to load all in one query
      clip = clips.find{|c| c.id == clip_id}
      artist = artists.find{|a|a.id == clip.artist_id}

      @rankings.push({
        :pointStart => min,
        :pointInterval => 1,
        :fullname => "#{artist.name} - #{clip.title}",
        :name => clip.title,
        :data => data
      })
    }

    result = {
      :series  => @rankings,
      :yAxis => {:min => y_min, :max => y_max},
      :xAxis => {:min => x_min, :max => x_max}
    }.to_json

    render :inline => result, :content_type => 'application/json'
  end

  def u objects
    Clip.all(id: objects.collect(&:id))
  end

  def classics
    params[:c] = 'title' unless Clip.properties[params[:c]] || ['in', 'gold'].include?(params[:c])
    @clips = golden_clips
    raw_aggregates = u(@clips).rankings.aggregate(:jtop_id.min, :jtop_id.max, :clip_id)
    @aggregates = Hash[raw_aggregates.collect{|a| [a[2], Hash[*[:min,:max,:id].zip(a).flatten]]}]
    @clips = sorted_clips
    @jtops = Hash[Jtop.all.collect {|jtop| [jtop.id, jtop]}]
  end

private
  def sorted_clips
    case params[:c]
    when 'in'
      @clips.sort! {|x,y| @aggregates[x.id][:min] <=> @aggregates[y.id][:min]}
    when 'gold'
      @clips.sort! {|x,y| @aggregates[x.id][:max] <=> @aggregates[y.id][:max]}
    else return @clips
    end
    @clips.reverse! if params[:d] == 'down'
    return @clips
  end

  def golden_clips
    case params[:c]
    when 'title'
      if params[:d] == 'down'
        Clip.classics.sort_by(&:sort_title).reverse!
      else
        Clip.classics.sort_by(&:sort_title)
      end
    when 'in', 'gold' then Clip.classics.all
    else Clip.classics.all(:order => sort_order)
    end
  end

end
