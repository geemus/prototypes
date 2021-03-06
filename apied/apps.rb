require './endpoint'

class Apps < Endpoint

  validates(:name, 'Name must start with a letter and can only contain lowercase letters, numbers, and dashes.') do
    data['name'] =~ /\A[a-z][a-z0-9-]*\z/
  end

  validates(:name, 'Name must be between three and thirty characters long.') do
    (3..30).include?(data['name'].length)
  end

  validates(:stack, 'Stack must be one of aspen-mri-1.8.6, bamboo-mri-1.9.2, bamboo-ree-1.8.7, bamboo-mri-1.9.1 or cedar.') do
    %w{aspen-mri-1.8.6 bamboo-mri-1.9.2 bamboo-ree-1.8.7 bamboo-mri-1.9.1 cedar}.include?(data[:stack])
  end

  delete('/:app') do
    description('Delete an app')

    response do
      response = heroku.delete_app(params[:app])
      status(response.status)
      body(response.body.to_json)
    end

    sample(<<-SAMPLE)
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
    SAMPLE
  end

  get do
    description('Get a listing of your apps.')

    response do
      response = heroku.get_apps
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

  get('/:app') do
    description('Get details for an app.')

    response do
      response = heroku.get_app(params[:app])
      status(response.status)
      body(response.body.to_json)
    end

    sample(<<-SAMPLE)
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
    SAMPLE
  end

  post do
    description('Create a new app.')

    accepts(:name,  'The String name for the app (default: randomly generated name).')
    accepts(:stack, 'The String technology stack to run app on (default: cedar).')

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

    accepts(:name,        'The new String name for app.')
    accepts(:maintenance, 'The Boolean maintenance mode status.')

    response do
      response = heroku.put_app(params[:app], request.body)
      status(response.status)
      body(response.body.to_json)
    end

    sample(<<-SAMPLE)
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
    SAMPLE
  end

  p Endpoint.data
  File.open('./output/apps.html', 'w+') {|file| file.write(to_html)}
  File.open('./output/apps.md', 'w+') {|file| file.write(to_md)}
  File.open('./output/apps.rb', 'w+') {|file| file.write(to_client)}

end
