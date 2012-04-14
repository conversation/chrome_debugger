require 'yaml'

module Configuration

  def librato
    YAML.load(File.open(File.expand_path('../librato.yml', __FILE__)))
  end

  def config
    YAML.load(File.open(File.expand_path('../config.yml', __FILE__)))
  end

  def instance
    Object.new.tap do |config|
      config.extend(Configuration)
    end
  end
  module_function :instance
end
