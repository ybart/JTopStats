class Clip

  include DataMapper::Resource

  property :id, Serial

  property :name, String
  property :featuring, String

  belongs_to :artist
end
