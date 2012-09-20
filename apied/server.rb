class Server < Sinatra::Base

  delete('/apps') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      []
    end
    model.delete(data)
  end

  delete('/apps/:id') do
    model.delete([params[:id]])
  end

  get('/apps') do
    model.all
  end

  get('/apps/:id') do
    model.get(params[:id])
  end

  head('/apps/:id') do
    model.head(params[:id])
  end

  options('/apps') do
    model.options
  end

  options('/apps/:id') do
    model.options(params[:id])
  end

  patch('/apps') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      []
    end
    model.update(data)
  end

  patch('/apps/:id') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      {}
    end
    model.update([{params[:id] => data}])
  end

  post('/apps') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      {}
    end
    model.create(data)
  end

  put('/apps') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      []
    end
    model.replace(data)
  end

  put('/apps/:id') do
    data = if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      {}
    end
    model.replace([{params[:id] => data}])
  end

end
