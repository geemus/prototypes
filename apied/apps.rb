require './endpoint'

class Apps < Endpoint

  delete('/:app') do
    description('Delete an app')
  end

  get do
    description('Get a listing of your apps.')
  end

  get('/:app') do
    description('Get details for an app.')
  end

  post do
    description('Create a new app.')

    accepts(:name,  'identifier for app (default: randomly generated name).')
    accepts(:stack, 'technology stack to run app on (default: cedar).')

    response do
      response = heroku.post_app(data)
      status(response.status)
      body(response.body.to_json)
    end

    sample(<<-SAMPLE)
[
  {
    "id": "app123@heroku.com",
    "owner_id": "user123@heroku.com",
    "name": "myapp",
    "created_at": "2012-01-01T12:00:00-00:00",
    "released_at": "2012-01-01T12:00:00-00:00",
    "repo_size": 1024,
    "slug_size": 1450,
    "stack": "cedar",
    "web_url": "http://myapp.herokuapp.com",
    "git_url": "git@heroku.com:myapp.git",
    "buildpack_provided_description": "Ruby/Rails",
    "maintenance": false,
  }
]
    SAMPLE
  end

  put('/:app') do
    description('Update an existing app.')
  end

  p data
  File.open('./output/apps.md', 'w+') {|file| file.write(to_md)}
  File.open('./output/apps.rb', 'w+') {|file| file.write(to_client)}

end
