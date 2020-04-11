require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include? RedmineAutoPercent::IssuePatch
    Issue.send(:include, RedmineAutoPercent::IssuePatch)
  end
end

Redmine::Plugin.register :redmine_crypto_salary do
  name 'Redmine crypto salary'
  author 'Open Yoga'
  description 'Automatically pays bitcoin/altcoin salary depends on done ratio percents on status Closed'
  version '0.0.1'
  url 'https://github.com/openyogaprojects/pranacoin-redmine'
  author_url 'http://openyogaclass.com'
end
