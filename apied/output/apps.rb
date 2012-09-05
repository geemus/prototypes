class Client

  def connection
    @connection ||= begin
      require('excon')
      Excon.new('http://localhost:9292')
    end
  end

  # Public: Delete an app
  #
  def delete_app(app)
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
  def get_app(app)
    connection.request(
      :method => :get,
      :path   => "/apps/#{app}"
    )
  end

  # Public: Create a new app.
  #
  # options - hash of options for operation (default: {})
  #           :name - The String name for the app (default: randomly generated name).
  #           :stack - The String technology stack to run app on (default: cedar).
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
  # options - hash of options for operation (default: {})
  #           :name - The new String name for app.
  #           :maintenance - The Boolean maintenance mode status.
  #
  def put_app(app, options = {})
    connection.request(
      :body   => options,
      :method => :put,
      :path   => "/apps/#{app}"
    )
  end

end
