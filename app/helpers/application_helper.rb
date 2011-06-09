module ApplicationHelper
  def title
    content_for?(:title) ? content_for(:title) : 'J-Top Stats'
  end
  
  def arrow column
   (params[:c].to_sym == column) ? (params[:d] == 'down' ? '&#x25bc;' : '&#x25b2;') : ''
  end
  
  def sort_dir column
    (params[:c].to_sym == column) ? (params[:d] == 'down' ? 'up' : 'down') : 'up'
  end
  
  def sort_link(title, column, options = {})
    #condition = options[:unless] if options.has_key?(:unless)
    #link_to_unless condition, title, request.parameters.merge( {:c => column, :d => sort_dir} )
    link_to(title, request.parameters.merge( {:c => column, :d => sort_dir(column)} )) + " #{arrow(column)}".html_safe
  end
  
  def javascripts folder
    Dir.glob("#{Rails.root}/public/javascripts/#{folder}/*").collect {|p|"#{folder}/#{p.split('/').last}"}
  end
  
  def charts_js
    content_for :js do javascript_include_tag 'highcharts', 'highcharts.gray', 'charts' end
  end
end
