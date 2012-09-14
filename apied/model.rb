class Apps

  param :name,
        :default      => 'randomly generated name',
        :description  => 'name for the app',
        :example      => 'freezing-winter-1234',
        :length       => 3..30,
        :matches      =>  /\A[a-z][a-z0-9-]*\z/,
        :type         => :string

  param :stack,
        :default      => 'cedar',
        :description  => 'technology stack for app',
        :in           => %w{aspen-mri-1.8.6 bamboo-mri-1.9.2 bamboo-ree-1.8.7 bamboo-mri-1.9.1 cedar},
        :type         => :string

end

# TomDoc style param description
data = "The #{type.capitalize} #{description}"
if default
  data << "(default: #{default})"
end
data << '.'

# json sample for help/options
sample <<-SAMPLE
{
  'name': '#{name.example || name.default || raise}',
  'stack': '#{stack.example || stack.default || raise}'
}
SAMPLE
