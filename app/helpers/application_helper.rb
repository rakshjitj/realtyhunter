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

  def wrap_text(text, max_char_count=15)
    words = text.strip.split(" ")
    puts "\n\n\n***** #{words.inspect}"
    out_text = ""

    # number of chars on current line
    char_count = 0
    words.each{|w|
      # if adding this next word puts us over the limit, break here
      if char_count + w.length + 1 > max_char_count
        out_text = out_text + "<br />&nbsp;&nbsp;"
        char_count = 0
      end

      out_text = out_text + w + " "
      char_count = char_count + w.length + 1
    }
    puts out_text
    out_text.html_safe
  end
end
