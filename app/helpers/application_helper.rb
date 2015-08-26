module ApplicationHelper
	# Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "RealtyHunter"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def rent_formatted(rent)
    number_to_currency(rent, {precision: 0})
  end

  def money_formatted(rent)
    number_to_currency(rent, {precision: 2})
  end

  def wrap_text(text, max_char_count=15)
    words = text.strip.split(" ")
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
    out_text.html_safe
  end
end
