class ClipsController < ApplicationController
  def chart
    @rankings = []
    min, max = Jtop.all.aggregate(:id.min, :id.max)
    rankings_by_clip_ids = Ranking.all(:clip_id => params[:clip_ids], :order => :jtop_id).group_by {|r|r.clip_id}
    rankings_by_clip_ids.each { |clip_id, rankings|
      rankings_by_jtop_id = {}
      (min..max).each { |jtop_id| rankings_by_jtop_id[jtop_id] = nil }
      rankings.each {|r| rankings_by_jtop_id[r.jtop_id] = r.rank }
      @rankings.push({
        :pointStart => min,
        :pointInterval => 1,
        :fullname => "#{rankings.first.clip.artist.name} - #{rankings.first.clip.title}",
        :name => rankings.first.clip.title,
        :data => rankings_by_jtop_id.sort.collect {|pair| pair[1]}
      }) 
    }
    
    result = {
      :series  => @rankings,
    }.to_json
    
    render :inline => result, :content_type => 'application/json'
  end
end
