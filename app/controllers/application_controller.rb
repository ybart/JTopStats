require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery
  
  rescue_from DataMapper::ObjectNotFoundError, :with => :render_404
  
private
  def render_error status
    render :file => "#{RAILS_ROOT}/public/#{status}.html", :status => status
  end
  
  def render_404
    render_error 404
  end
  
  def sort_order(default=:id)
    #{}"#{(params[:c] || default.to_s).gsub(/[\s;'\"]/,'')} #{params[:d] == 'down' ? 'DESC' : 'ASC'}"
    column = (params[:c] || default.to_s).gsub(/[\s;'\"]/,'').to_sym
    params[:d] == 'down' ? column.desc : column
  end  
end
