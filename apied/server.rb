class Server < Sinatra::Base

#  def batch_data
#    @batch_data ||= if (body = request.body.read) && !body.empty?
#      JSON.parse(body)
#    else
#      []
#    end
#  end

  def data
    @data ||= if (body = request.body.read) && !body.empty?
      JSON.parse(body)
    else
      {}
    end
  end

#  delete('/apps') do
#    model.delete(batch_data)
#  end

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

#  patch('/apps') do
#    model.update(batch_data)
#  end

  patch('/apps/:id') do
    model.update([{params[:id] => data}])
  end

  post('/apps') do
    model.create(data)
  end

#  put('/apps') do
#    model.replace(batch_data)
#  end

  put('/apps/:id') do
    model.replace([{params[:id] => data}])
  end

end
