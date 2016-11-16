require File.expand_path('../../test_helper', __FILE__)

class InheritIssueSettingsTest < ActionController::TestCase
  tests SettingsController
  fixtures :users, :custom_fields
  
  setup do
	session[:user_id] = 1 #test as admin
  end
	 
  test 'should render settings' do
	get :plugin, id: 'redmine_inherit_issue'
	
	CustomField.all.each do |custom_field|
		assert_select 'option', "#{custom_field.name}"
	end
    
  end
end
