class Ranking

  include DataMapper::Resource

  property :id, Serial

  property :rank, Integer
  property :progress, Integer
  property :vote_count, Integer
  property :votes, Integer
  property :score, Integer
  property :total, Integer

  belongs_to :artist
  belongs_to :clip
  belongs_to :jtop
end
