require File.expand_path('../../test_helper', __FILE__)

#require 'projects_controller'
include InheritIssuesHelper

class RedmineInheritIssue::InheritIssuesCustomFieldsVisibilityTest < ActionController::TestCase
	tests IssuesController
	include QueriesHelper
	
    fixtures :projects,
		   :users,
		   :roles,
		   :issue_statuses,
		   :trackers,
		   :projects_trackers,
		   :enabled_modules,
		   :enumerations,
		   :workflows
	
	include Redmine::I18n
	
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
		
		@issues << @issue2 = Issue.create!( :author_id => 1, :project_id => 1, :tracker_id => 1, :subject => 'First Child', :parent_issue_id => @issue1.id, :root_id => 1)
		@issues << @issue3 = Issue.create!( :author_id => 1, :project_id => 1, :tracker_id => 1, :subject => 'First Grand Child', :parent_issue_id => @issue2.id, :root_id => 1)

	end
	
	def test_index_with_csv
		Setting.plugin_redmine_inherit_issue['ancestor_attribute'] = CustomField.first.id.to_s	
		column_name="cf_#{get_custom_field_id}"		


		get :index, :format => 'csv', :csv => {:columns => 'all'}
		assert_response :success
		@issues.each do |issue|
		  	issue_line = response.body.chomp.split("\n").map {|line| line.split(',')}.detect {|line| line[0]==issue.id.to_s}
			assert_include 'Value0', issue_line
		end		
	end
	
	def test_index_with_custom_field_column
		Setting.plugin_redmine_inherit_issue['ancestor_attribute'] = CustomField.first.id.to_s
		column_name="cf_#{get_custom_field_id}"
		get :index, :c => [column_name]
		assert_response :success

		assert_select "table.issues td.#{column_name}.string"
		assert_select 'td', {:count=>@issues.count, :text=>"Value0"} 
    end

	
	test 'test for correct inheritance at single issue' do
		CustomField.all.each do |custom_field|
			Setting.plugin_redmine_inherit_issue['ancestor_attribute'] = custom_field.id.to_s			
			
			@issues.each do |issue|
				get :show, id: issue.id
				unless issue.parent.nil? 
					ancestor_val = issue.find_ancestor_attribute
					assert_equal ancestor_val, 'Value0'
					assert_select 'span', {:text => "#{custom_field.name}*:", :count => 1}, "Label for CustomField: \"#{custom_field.name}*:\" error"
					if Redmine::VERSION::MAJOR < 3
						assert_select 'td', {:count=>1, :text=>"#{ancestor_val}"}, "Ancestor Value: \"#{ancestor_val}\" not found"
					else
						assert_select "div:match('id', ?)", "inherit_#{custom_field.name}", {:count=>1, :text=>"#{ancestor_val}"}, "Ancestor Value: \"#{ancestor_val}\" not found"
					end
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
		assert_select 'span', {:text => "#{custom_field.name}*:", :count => 0}, "Hide at root does not work"
		
		#2 should show empty value at root level
		Setting.plugin_redmine_inherit_issue['root_hide'] = "0"
		Setting.plugin_redmine_inherit_issue['ancestor_notset_hide'] = "0"
		get :show, id: @issue1.id
		assert_select 'span', {:text => "#{custom_field.name}*:", :count => 1}, "Show empty at root does not work"
		
		#3 hide if ancestor notset
		Setting.plugin_redmine_inherit_issue['root_hide'] = "0"
		Setting.plugin_redmine_inherit_issue['ancestor_notset_hide'] = "1"
		get :show, id: @issue1.id
		assert_select 'span', {:text => "#{custom_field.name}*:", :count => 0}, "Hide empty ancestor value not working"
	end
end