class Clip

  include DataMapper::Resource

  property :id, Serial

  property :title, String
  property :featuring, String

  belongs_to :artist
end
