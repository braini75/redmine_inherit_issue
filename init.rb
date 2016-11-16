Redmine::Plugin.register :redmine_inherit_issue do  
  name 'Redmine Inherit Issue Attributes'
  author 'Thomas Koch'
  description 'This is a plugin for Redmine to display Issue Attributes from ancestor Issues.'
  version '1.0'
  url 'https://github.com/braini75/redmine_inherit_issue'
  author_url 'https://github.com/braini75'  
  
  settings :default => {
    :root_hide => 1,
	:ancestor_notset_hide => 1,
    :ancestor_attribute   => 0,
    }, :partial => 'settings/inherit_issue_settings' 
end

require_dependency 'redmine_inherit_issue'

Rails.configuration.to_prepare do 
   RedmineInheritIssue.setup 
end 
