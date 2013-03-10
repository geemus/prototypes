require 'formatador'
require 'time'

dates = ARGV

month = []
today = first = last = Time.now.to_date

until (first.day == 0 && first.wday == 0) || (first.month < today.month && first.wday == 0)
  first = first.prev_day
end
until (last.month > today.month && last.wday == 6)
  last = last.next_day
end
if last.day == 7
  last = last.prev_week
end

current, current_week = first, first.strftime('%U')
while current <= last
  week = {}
  while current.strftime('%U') == current_week
    data = current.strftime('%d')
    if current.month == today.month
      data = "[bold]#{data}[/]"
    end
    if current.day == today.day
      data = "[underline]#{data}[/]"
    end

    if dates.include?(current.strftime('%Y-%m-%d'))
      data = "[negative]#{data}[/]"
    end

    week[current.strftime('%a')[0,2]] = data
    current = current.next_day
  end
  month << week
  current_week = current.strftime('%U')
end

Formatador.display_table(month, ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])
