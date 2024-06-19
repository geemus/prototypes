# frozen_string_literal: true

require 'sqlite3'

# TODO: copy database directly from kobo to tmp

db = SQLite3::Database.new('/tmp/KoboReader.sqlite')

# FIXME: ? annotations (if any)
# TODO: limit to relevant columns
columns, *rows = db.execute2(
  'SELECT * from Bookmark INNER JOIN Content ON Bookmark.ContentID = Content.ContentID WHERE Bookmark.Type = "highlight" ORDER BY Bookmark.ContentID'
)

bookmarks = rows.map { |row| Hash[columns.zip(row)] }

title = nil
chapter = nil

# TODO: create a directory in tmp for output
# TODO: write each book to it's own md file within dir
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
    # assume that first highlight in the chapter is the title, so that we can include them
    puts "## #{bookmark['Text']}"
    next
  end

  text = bookmark['Text']
  text = text.split("\n").join("\n    ")
  puts "- #{text}"
end
