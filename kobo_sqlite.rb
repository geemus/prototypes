# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

FileUtils.cp(
  '/media/geemus/KOBOeReader/.kobo/KoboReader.sqlite',
  '/tmp/KoboReader.sqlite'
)

db = SQLite3::Database.new('/tmp/KoboReader.sqlite')

columns, *rows = db.execute2(
  'SELECT * from Bookmark'
)

# FIXME: ? annotations (if any)
# TODO: limit to relevant columns
columns, *rows = db.execute2(
  'SELECT * from Bookmark INNER JOIN Content ON Bookmark.ContentID = Content.ContentID WHERE Bookmark.Type = "highlight" ORDER BY Bookmark.VolumeID, Bookmark.ContentID ASC, Bookmark.ChapterProgress ASC, Bookmark.StartContainerPath ASC'
)
bookmarks = rows.map { |row| Hash[columns.zip(row)] }

title = nil
chapter = nil
chapter_title = false
data = nil

FileUtils.mkdir_p('/tmp/kobo')

# TODO: write each book to it's own md file within dir

def write_file(title, data)
  return if data.nil?

  filename = title.gsub(/[^0-9A-Za-z.-]/, '_').gsub(/_{2,}/, '_')
  path = "/tmp/kobo/#{filename}.md"
  File.write(path, data)
  puts "wrote #{path}"
end

bookmarks.each do |bookmark|
  if title != bookmark['BookTitle']
    write_file(title, data)
    title = bookmark['BookTitle']
    data = +''
    columns, *rows = db.execute2("SELECT * from Content WHERE ContentID = '#{bookmark['VolumeID']}'")
    book = Hash[columns.zip(rows.first)]
    data << "# *#{title}* by #{book['Attribution']}\n"
  end

  if chapter != bookmark['Title']
    chapter = bookmark['Title']
    chapter_title = false
  end

  text = "#{bookmark['Text']} <#{bookmark['ChapterProgress']}#{bookmark['StartContainerPath'].gsub(/[^\d.]*/, '')}>"

  # Titlecase
  if text.split.count { |x| /[[:upper:]]/.match(x[0]) } > text.split.count { |x| /[[:lower:]]/.match(x[0]) }
    if chapter_title
      text = "### #{text}"
    else
      text = "## #{text}"
      chapter_title = true
    end
  else
    text = "- #{text}"
  end

  text = text.split("\n").join("\n    ") if text
  data << "#{text}\n"
end
write_file(title, data)
