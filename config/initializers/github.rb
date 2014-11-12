MY_APP = YAML.load(
  File.read("#{Rails.root}/config/github.yml"))[Rails.env]
