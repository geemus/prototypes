module Boolean; end
[FalseClass, TrueClass].each {|klass| klass.send(:include, Boolean)}

class Apps

  def self.attributes=(new_attributes)
    @attributes = new_attributes
  end

  def self.attributes
    @attributes ||= Hash.new {|hash,key| hash[key] = {}}
  end

  def self.attribute(name, data={})
    unless data.has_key?(:type)
      raise StandardError.new(":type is required for #{name}")
    end

    # TODO: should raise errors on unknown attribute properties

    self.attributes[name] = data
  end

  def self.validate(data)
    errors = []
    data.each do |key, value|
      unless self.attributes.has_key?(key)
        errors << "#{key} is not a recognized attribute."
      else
        attribute = self.attributes[key.to_sym]

        if attribute.has_key?(:within) && (within = attribute[:within]) && !within.include?(value)
          values = within[0...-1].join(', ') + ", or #{within.last}"
          errors << "#{key} must be one of #{values}."
        end

        if attribute.has_key?(:length) && (length = attribute[:length]) && !length.include?(value.length)
          if value.length < length.first
            errors << "#{key} must be longer than #{length.first} characters."
          elsif value.length > length.last
            errors << "#{key} must be shorter than #{length.last} characters."
          end
        end

        if attribute.has_key?(:matches) && !(attribute[:matches] =~ value)
          errors << "#{key} must match #{attribute[:matches].inspect}."
        end

        unless (type = attribute[:type]) == value.class
          article = if %w{a e i o u}.include?(type.to_s[0..0].downcase)
            'an'
          else
            'a'
          end
          errors << "#{key} must be #{article} #{type}."
        end

      end
    end
    return errors.empty?, errors
  end

  # TomDoc style documentation, similar to:
  # The TYPE DESCRIPTION (default: DEFAULT).
  def self.to_doc
    doc = "#{name}:\n\n"
    key_length = self.attributes.keys.map {|key| key.to_s.length}.max
    self.attributes.keys.sort.each do |attribute|
      data = self.attributes[attribute]
      doc << "#{attribute.to_s.ljust(key_length)} - "
      if data[:immutable]
        doc << "[immutable] "
      end
      doc << "The #{data[:type]} #{data[:description]}"
      if data[:default]
        doc << " (default: #{data[:default]})"
      end
      doc << ".\n"
    end
    doc << "\nSample:\n\n"
    doc << self.to_sample
    doc
  end

  def self.to_sample
    sample = "{\n"
    key_length = self.attributes.keys.map {|key| key.to_s.length}.max
    self.attributes.keys.sort.each do |attribute|
      data = self.attributes[attribute]
      key = "'#{attribute}':".ljust(key_length + 3)
      sample << "  #{key} "

      value = if data.has_key?(:example)
        data[:example]
      elsif data.has_key?(:default)
        data[:default]
      else
        raise(StandardError.new("no example or default for #{attribute}"))
      end

      if [Boolean, Integer].include?(data[:type])
        sample << value.to_s
      elsif [String, Time].include?(data[:type])
        sample << "'#{value}'"
      end

      sample << ",\n"
    end
    sample << "}\n"
    sample
  end

  attribute :buildpack_provided_description,
            :description  => 'description of buildpack for app',
            :example      => 'Ruby/Rails',
            :immutable    => true,
            :type         => String

  attribute :created_at,
            :description  => 'when app was created',
            :example      => '2012-01-01T12:00:00-00:00',
            :immutable    => true,
            :type         => Time

  attribute :git_url,
            :description  => 'url where site repo is stored',
            :example      => 'git@heroku.com:freezing-winter-1234.git',
            :immutable    => true,
            :type         => String

  attribute :id,
            :description  => 'unique identifier for the app',
            :example      => 'app123@heroku.com',
            :immutable    => true,
            :type         => String

  attribute :maintenance,
            :description  => 'maintenance status of app',
            :example      => false,
            :immutable    => true,
            :type         => Boolean

  attribute :name,
            :default      => 'randomly generated name',
            :description  => 'name for the app',
            :example      => 'freezing-winter-1234',
            :length       => 3..30,
            :matches      => /\A[a-z][a-z0-9-]*\z/,
            :type         => String

  attribute :owner_id,
            :description  => 'unique identifier for the owner of the app',
            :example      => 'user123@heroku.com',
            :type         => String

  attribute :released_at,
            :description  => 'when app was last released',
            :example      => '2012-01-01T13:00:00-00:00',
            :immutable    => true,
            :type         => Time

  attribute :repo_size,
            :description  => 'size in bytes of the app repository',
            :example      => 1024,
            :immutable    => true,
            :type         => Integer

  attribute :slug_size,
            :description  => 'size in bytes of the app slug',
            :example      => 1450,
            :immutable    => true,
            :type         => Integer

  attribute :stack,
            :default      => 'cedar',
            :description  => 'technology stack for app',
            :within       => %w{aspen-mri-1.8.6 bamboo-mri-1.9.2 bamboo-ree-1.8.7 bamboo-mri-1.9.1 cedar},
            :type         => String

  attribute :web_url,
            :description  => 'url where site is available',
            :example      => 'http://freezing-winter-1234.herokuapp.com',
            :immutable    => true,
            :type         => String

  # TODO: immutable attributes (ie created_at shouldn't change)
end

puts
print Apps.to_doc
puts

validations = [
  { :name   => 'ab' },
  { :name   => '24hours' },
  { :name   => 'myapp' },
  { :stack  => 'foo' }
]

validations.each do |validation|
  valid, errors = Apps.validate(validation)
  puts("Apps.validate(#{validation.inspect}) # => #{valid}")
  unless errors.empty?
    puts errors.join("\n")
  end
  puts
end

