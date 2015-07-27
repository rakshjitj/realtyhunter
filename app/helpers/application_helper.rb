module ApplicationHelper
	# Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "RealtyMonster"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort_by] && params[:direction] == "asc") ? "desc" : "asc"
    # toggle arrow
    if direction == "desc"
      css_class = "glyphicon glyphicon-triangle-top"
    elsif direction == "asc"
      css_class = "glyphicon glyphicon-triangle-bottom"
    end

    link_to "<i class=\"#{css_class}\"></i> #{title}".html_safe, {:sort_by => column, :direction => direction}
  end

  def rent_formatted(rent)
    number_to_currency(rent, {precision: 0})
  end

  def money_formatted(rent)
    number_to_currency(rent, {precision: 2})
  end
end
