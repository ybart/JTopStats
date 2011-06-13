module DataMapper
  module Adapters
    class DataObjectsAdapter < AbstractAdapter
      def select_statement(query)
        qualify  = query.links.any?
        fields   = query.fields
        order_by = query.order
        group_by = if query.unique?
          group_by_fields = order_by.collect { |direction| direction.target.property }
          Set.new(fields).merge(group_by_fields).select { |property| property.kind_of?(Property) }
        end

        conditions_statement, bind_values = conditions_statement(query.conditions, qualify)

        statement = "SELECT #{columns_statement(fields, qualify)}"
        statement << " FROM #{quote_name(query.model.storage_name(name))}"
        statement << " #{join_statement(query, bind_values, qualify)}"   if qualify
        statement << " WHERE #{conditions_statement}"                    unless DataMapper::Ext.blank?(conditions_statement)
        statement << " GROUP BY #{columns_statement(group_by, qualify)}" if group_by && group_by.any?
        statement << " ORDER BY #{order_statement(order_by, qualify)}"   if order_by && order_by.any?

        add_limit_offset!(statement, query.limit, query.offset, bind_values)

        return statement, bind_values
      end
    end
  end
end

class Ranking

  include DataMapper::Resource

  property :id, Serial

  property :rank, Integer
  property :progress, Integer
  property :vote_count, Integer
  property :vote_score, Integer
  property :pal_count, Integer
  property :pal_score, Integer

  belongs_to :clip  
  belongs_to :jtop
  belongs_to :prev_jtop, 'Jtop', :required => false
  
  has 1, :artist, :through => :clip
  #has 1, :prev_ranking, 'Ranking', :jtop_id => Ranking.all(:jtop_id.lt => jtop_id).aggregate(:jtop_id.max), :clip_id => clip_id
  
  def prev_ranking
    Ranking.all(:jtop_id => Ranking.all(:jtop_id.lt => jtop_id, :clip_id => clip_id).aggregate(:jtop_id.max), :clip_id => clip_id).first
  end
  
  def formatted_progress controller
    return I18n.t 'ranking.in' if prev_jtop_id.nil?
    
    plus = progress > 0 ? '+' : ''
    str = "#{plus}#{progress}".html_safe
    
    return  controller.link_to("#{str}*", controller.jtop_path(prev_jtop_id)) if jtop_id != prev_jtop_id + 1
    return str
  end
  
  def self.sorted_by_clips direction=:asc
    artist_name = DataMapper::Query::Direction.new(clip.artist.name, direction)
    clip_title = DataMapper::Query::Direction.new(clip.title, direction)
    
    query = all.query.update(:order => [artist_name, clip_title], 
                             :links => [Clip.relationships['artist'].inverse, relationships['clip'].inverse])
    all(query)
  end  
end
