class ClipsController < ApplicationController
  def chart
    #render :inline => "Please choose at least 1 and at most 20 clips.", status => 400 and return unless params[:clip_ids] && (1..20).include?(params[:clip_ids].count)
    
    @rankings = []
    jtop_id = params[:jtop_id].to_i
    min, max = Ranking.all(:clip_id => params[:clip_ids]).aggregate(:jtop_id.min, :jtop_id.max)
    min = [min, jtop_id-25].max
    max = [max, min+50].min
    
    rankings = Ranking.all(:clip_id => params[:clip_ids], :order => :jtop_id, :jtop_id.gte => min, :jtop_id.lte => max)
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
      :yAxis => {:min => y_min, :max => y_max}
    }.to_json
    
    render :inline => result, :content_type => 'application/json'
  end
end
