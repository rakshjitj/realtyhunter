module ApplicationHelper
	# Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "RealtyHunter"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}".freeze
    end
  end

  def trim_zeros cell
    if cell.is_a?(Float)
      i = cell.to_i
      cell == i.to_f ? i : cell
    else
      cell
    end
  end

  def rent_formatted(rent)
    number_to_currency(rent, {precision: 0})
  end

  def money_formatted(rent)
    number_to_currency(rent, {precision: 2})
  end

  def url_with_protocol(url)
    /^http/i.match(url) ? url : "http://#{url}"
  end

  def unread_roommates_count
    Roommate.where(archived: false, read: false).count
  end

  def symbolize_params_without_controller(params_obj)
    params_obj.delete('action')
    params_obj.delete('controller')
    params_obj.to_h
  end

end
