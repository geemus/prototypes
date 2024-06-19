# frozen_string_literal: true

require 'sqlite3'

db = SQLite3::Database.new('/tmp/KoboReader.sqlite')

# FIXME: ? bookmark annotations (if any)
columns, *rows = db.execute2(
  'SELECT * from Bookmark INNER JOIN Content ON Bookmark.ContentID = Content.ContentID WHERE Bookmark.Type = "highlight" ORDER BY Bookmark.ContentID'
)

bookmarks = rows.map { |row| Hash[columns.zip(row)] }

title = nil
chapter = nil

bookmarks.each do |bookmark|
  if title != bookmark['BookTitle']
    title = bookmark['BookTitle']
    columns, *rows = db.execute2(
      "SELECT * from Content WHERE ContentID = '#{bookmark['VolumeID']}'"
    )
    book = Hash[columns.zip(rows.first)]
    puts book
    puts "# *#{title}* by #{book['Attribution']}"
  end
  if chapter != bookmark['Title']
    chapter = bookmark['Title']
    puts "## #{chapter}"
  end

  text = bookmark['Text']
  text = text.split("\n").join("\n    ")
  puts "- #{text}"
end
