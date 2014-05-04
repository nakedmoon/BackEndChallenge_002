module GamesHelper


  def summary(points)
    case
      when points[0] > points[1]
        label = "You win!"
        td_class = 'success'
      when points[0] < points[1]
        label = "You loose!"
        td_class = 'danger'
      when points[0] = points[1]
        label = "You draw!"
        td_class = 'info'
    end
    content_tag(:td, "Summary: #{points[0]} - #{points[1]} #{label}", :colspan => 4, :id => 'game_summary', :class => td_class).html_safe
  end


end
