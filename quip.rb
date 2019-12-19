require 'excon'
require 'json'

year_and_month = ARGV[0] || Time.now.strftime("%Y/%m")

connection = Excon.new(
  'https://platform.quip.com',
  headers: {
    'Authorization' => "Bearer #{ENV['QUIP_TOKEN']}"
  }
)

# decision records

# get final folder+subolders and build full list of thread ids
puts "Decision Records > Final"
puts " -> get folder"
final_folder_response = connection.get(path: '/1/folders/XAcAOAgra75')
# children look like [ { "folder_id" => "..." }, { "thread_id" => "..." }, { ... } ]
final_folder_children = JSON.parse(final_folder_response.body)['children']
thread_ids = final_folder_children.select {|child| child.has_key?('thread_id')}.map {|child| child['thread_id']}

subfolder_ids = final_folder_children.select {|child| child.has_key?('folder_id')}.map {|child| child['folder_id']}
puts " -> get subfolders [#{subfolder_ids.join(',')}]"
subfolders_response = connection.get(
  path: '/1/folders/',
  query: { ids: subfolder_ids.join(',') }
)
JSON.parse(subfolders_response.body).each do |key, value|
  thread_ids.concat value['children'].select {|child| child.has_key?('thread_id')}.map {|child| child['thread_id']}
end

# get all threads in final folder, collect titles and author_ids
puts " -> get threads [#{thread_ids.join(',')}]"
threads_response = connection.get(
  path: '/1/threads/',
  query: { ids: thread_ids.join(',') }
)
author_ids = []
dr_threads = {}
JSON.parse(threads_response.body).each do |key, value|
  thread = value['thread']
  dr_threads[key] = {
    author_id:  thread['author_id'],
    link:       thread['link'],
    title:      thread['title']
  }
  author_ids.append(value['thread']['author_id'])
end

# get all authors
puts " -> get authors [#{author_ids.join(',')}]"
dr_authors = {}
users_response = connection.get(
  path: '/1/users/',
  query: { ids: author_ids.join(',') }
)
JSON.parse(users_response.body).each do |key, value|
  dr_authors[key] = value['name']
end
puts

# requests for comment
puts "Request for Comments > Final"
puts " -> get folder"
final_folder_response = connection.get(path: '/1/folders/YNEAOAa9GEk')
final_folder_children = JSON.parse(final_folder_response.body)['children']
thread_ids = final_folder_children.select {|child| child.has_key?('thread_id')}.map {|child| child['thread_id']}

# get all threads in final folder, collect titles and author_ids
puts " -> get threads [#{thread_ids.join(',')}]"
threads_response = connection.get(
  path: '/1/threads/',
  query: { ids: thread_ids.join(',') }
)
author_ids = []
rfc_threads = {}
JSON.parse(threads_response.body).each do |key, value|
  thread = value['thread']
  rfc_threads[key] = {
    author_id:  thread['author_id'],
    link:       thread['link'],
    title:      thread['title']
  }
  author_ids.append(value['thread']['author_id'])
end

# get all authors
puts " -> get authors [#{author_ids.join(',')}]"
rfc_authors = {}
users_response = connection.get(
  path: '/1/users/',
  query: { ids: author_ids.join(',') }
)
JSON.parse(users_response.body).each do |key, value|
  rfc_authors[key] = value['name']
end
puts

# Architectural Plans
puts "Architectural Plans > Final"
puts " -> get folder"
final_folder_response = connection.get(path: '/1/folders/BDUAOAEUJHX')
final_folder_children = JSON.parse(final_folder_response.body)['children']
thread_ids = final_folder_children.select {|child| child.has_key?('thread_id')}.map {|child| child['thread_id']}

# get all threads in final folder, collect titles and author_ids
puts " -> get threads [#{thread_ids.join(',')}]"
threads_response = connection.get(
  path: '/1/threads/',
  query: { ids: thread_ids.join(',') }
)
author_ids = []
architectural_plans_threads = {}
JSON.parse(threads_response.body).each do |key, value|
  thread = value['thread']
  architectural_plans_threads[key] = {
    author_id:  thread['author_id'],
    link:       thread['link'],
    title:      thread['title']
  }
  author_ids.append(value['thread']['author_id'])
end

# get all authors
puts " -> get authors [#{author_ids.join(',')}]"
architectural_plans_authors = {}
users_response = connection.get(
  path: '/1/users/',
  query: { ids: author_ids.join(',') }
)
JSON.parse(users_response.body).each do |key, value|
  architectural_plans_authors[key] = value['name']
end
puts

# stitch together RFC output
puts
rfc_threads.keys.sort_by {|key| rfc_threads[key][:title]}.each do |key|
  value = rfc_threads[key]
  next unless value[:title][0..6] == year_and_month
  puts "#{value[:title]} by #{rfc_authors[value[:author_id]]} #{value[:link]}"
end

puts

# stitch together Architectural Plans output
puts
architectural_plans_threads.keys.sort_by {|key| architectural_plans_threads[key][:title]}.each do |key|
  value = architectural_plans_threads[key]
  next unless value[:title][0..6] == year_and_month
  puts "#{value[:title]} by #{architectural_plans_authors[value[:author_id]]} #{value[:link]}"
end

puts

# stitch together DR output
puts
dr_threads.keys.sort_by {|key| dr_threads[key][:title]}.each do |key|
  value = dr_threads[key]
  next unless value[:title][0..6] == year_and_month
  puts "#{value[:title]} by #{dr_authors[value[:author_id]]} #{value[:link]}"
end

puts
