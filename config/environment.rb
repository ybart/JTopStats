# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
JTopStats::Application.initialize!

DataMapper::Logger.new($stderr, :debug)
