# Apps
## DELETE /apps/:app

*Delete an app*

### Sample Response

```
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
```
## GET /apps

*Get a listing of your apps.*

### Sample Response

```
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
```
## GET /apps/:app

*Get details for an app.*

### Sample Response

```
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
```
## POST /apps

*Create a new app.*

### Params

#### Accepts

* `name` - The String name for the app (default: randomly generated name).
* `stack` - The String technology stack to run app on (default: cedar).

### Sample Response

```
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
```
## PUT /apps/:app

*Update an existing app.*

### Params

#### Accepts

* `name` - The new String name for app.
* `maintenance` - The Boolean maintenance mode status.

### Sample Response

```
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
```