require File.expand_path('../../test_helper', __FILE__)

#require 'projects_controller'

class RedmineInheritIssue::InheritIssuesCustomFieldsVisibilityTest < ActionController::TestCase
	tests IssuesController
    fixtures :projects,
		   :users,
		   :roles,
		   :issue_statuses,
		   :trackers,
		   :projects_trackers,
		   :enabled_modules,
		   :enumerations,
		   :workflows
	
	def setup
		CustomField.delete_all
		Issue.delete_all	
		field_attributes = {:field_format => 'string', :is_for_all => true, :is_filter => true, :trackers => Tracker.all}		
		@fields = []
		@fields << (@field1 = IssueCustomField.create!(field_attributes.merge(:name => 'Field 1', :visible => true)))
		# maybe more to test?
		
		@issues = []
		@issues << @issue1 = Issue.generate!(
			:author_id => 1,
			:project_id => 1,
			:tracker_id => 1,
			:subject => 'Root Issue',
			:custom_field_values => {@field1.id => 'Value0'}
		)
		
		@issues << @issue2 = Issue.generate!( :author_id => 1, :project_id => 1, :tracker_id => 1, :subject => 'First Child', :parent_issue_id => @issue1.id, :root_id => 1)
		@issues << @issue3 = Issue.generate!( :author_id => 1, :project_id => 1, :tracker_id => 1, :subject => 'First Grand Child', :parent_issue_id => @issue2.id, :root_id => 1)
	end
	
	test 'test for correct inheritance' do
		CustomField.all.each do |custom_field|
			Setting.plugin_redmine_inherit_issue['ancestor_attribute'] = custom_field.id.to_s
#			@custom_field_name = CustomField.find(custom_field.id).name
#			assert_equal custom_field.name, @custom_field_name
			@issues.each do |issue|
				get :show, id: issue.id
				unless issue.parent.nil? 
					ancestor_val = issue.find_ancestor_attribute
					assert_equal ancestor_val, 'Value0'
					assert_select "span:match('title', ?)", I18n.t(:view_attribute_label) , {:count=>1, :text=>"#{custom_field.name}*:"}, "Label for CustomField: \"#{custom_field.name}*:\" error"
					assert_select "div:match('id', ?)", "inherit_#{custom_field.name}", {:count=>1, :text=>"#{ancestor_val}"}, "Ancestor Value: \"#{ancestor_val}\" not found"
				end
			end	
			
		end
	end
	
	test 'hide at root issue' do
		custom_field = CustomField.first
		Setting.plugin_redmine_inherit_issue['ancestor_attribute'] = custom_field.id.to_s
		#1 should not show any value at root level
		Setting.plugin_redmine_inherit_issue['root_hide'] = "1"
		Setting.plugin_redmine_inherit_issue['ancestor_notset_hide'] = "0"
		get :show, id: @issue1.id
		assert_select "div:match('id', ?)", "inherit_#{custom_field.name}", {:count=>0}, "Hide at root does not work"
		
		#2 should show empty value at root level
		Setting.plugin_redmine_inherit_issue['root_hide'] = "0"
		Setting.plugin_redmine_inherit_issue['ancestor_notset_hide'] = "0"
		get :show, id: @issue1.id
		assert_select "div:match('id', ?)", "inherit_#{custom_field.name}", {:count=>1}, "Show empty at root does not work"
		
		#3 hide if ancestor notset
		Setting.plugin_redmine_inherit_issue['root_hide'] = "0"
		Setting.plugin_redmine_inherit_issue['ancestor_notset_hide'] = "1"
		get :show, id: @issue1.id
		assert_select "div:match('id', ?)", "inherit_#{custom_field.name}", {:count=>0}, "Hide empty ancestor value not working"
	end
end