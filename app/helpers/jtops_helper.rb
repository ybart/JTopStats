module JtopsHelper
  def quick_nav
    nav = ""
    nav += link_to 'Précédent', jtop_path(@jtop.id - 1) if @jtop.id > 2
    nav += ' | ' + link_to('Suivant', jtop_path(@jtop.id + 1)) if @jtop.id < Jtop.aggregate(:id.max)
    nav += " | Aller au J-Top:" + form_tag(jtops_path, :method => :get, :class => 'inline') do
      text_field_tag(:id, nil, :size => 3) + submit_tag('Go')
    end
    return nav.html_safe
  end
end
