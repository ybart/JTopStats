module JtopsHelper
  def quick_nav
    nav = ""
    nav += link_to I18n.t('previous'), jtop_path(@jtop.id - 1) if @jtop.id > 2
    nav += ' | ' + link_to(I18n.t('next'), jtop_path(@jtop.id + 1)) if @jtop.id < Jtop.aggregate(:id.max)
    nav += ' | ' + I18n.t('jtop.go') + form_tag(jtops_path, :method => :get, :class => 'inline') do
      text_field_tag(:id, nil, :size => 3) + submit_tag('Go')
    end
    return nav.html_safe
  end
end
