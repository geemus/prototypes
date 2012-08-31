class Client

  # Public: Delete an app
  #
  def delete_apps(app)
    connection.request(
      :method => :delete,
      :path   => "/apps/#{app}"
    )
  end

  # Public: Get a listing of your apps.
  #
  def get_apps
    connection.request(
      :method => :get,
      :path   => "/apps"
    )
  end

  # Public: Get details for an app.
  #
  def get_apps(app)
    connection.request(
      :method => :get,
      :path   => "/apps/#{app}"
    )
  end

  # Public: Create a new app.
  #
  # options - hash of options for operation (default: {})
  #           :name - identifier for app (default: randomly generated name).
  #           :stack - technology stack to run app on (default: cedar).
  #
  def post_apps(options = {})
    connection.request(
      :body   => options,
      :method => :post,
      :path   => "/apps"
    )
  end

  # Public: Update an existing app.
  #
  def put_apps(app)
    connection.request(
      :method => :put,
      :path   => "/apps/#{app}"
    )
  end

end
