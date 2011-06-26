module ClipsHelper
  def dates_for clip
    min_jtop = @jtops[@aggregates[clip.id][:min]]
    max_jtop = @jtops[@aggregates[clip.id][:max]]

    [min_jtop.aired_at, max_jtop.aired_at]
  end
end
