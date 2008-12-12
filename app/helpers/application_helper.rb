# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  def cloud_classes
    %w(css1 css2 css3 css4 css5 css6 css7 css8 css9 css10)
  end
  def formatted_duration (seconds)
    return "" if seconds == 0
    m = (seconds/60).floor
    s = (seconds - (m * 60)).round
# add leading zero to one-digit minute
    if m < 10 then
      m = "0#{m}"
    end
# add leading zero to one-digit second
    if s < 10 then
      s = "0#{s}"
    end
# return formatted time
    return "#{m}:#{s}"
  end
end
