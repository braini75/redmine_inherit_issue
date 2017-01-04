module RedmineInheritIssue
	module QueriesHelperPatch
		def self.apply
			QueriesHelper.class_eval do												
				if RUBY_VERSION >= "2.0"
					prepend InstanceMethods
				else
					QueriesHelper.send(:include, QueriesHelperPatch)
				end

				alias_method_chain :column_value, :inheritance
				alias_method_chain :csv_value, :inheritance
			end unless QueriesHelper < InstanceMethods			
		end
		
		# for compatiblity reasons (ruby < 2.0 does not support prepend)
		def self.included(base)
			base.send(:include, InstanceMethods) 
		end			
	  
	  module InstanceMethods
		
		#Adds inherit value if exists to column_value(column, issue, value)
		def column_value_with_inheritance(column, issue, value)
			case column.name			
			when :"cf_#{get_custom_field_id}"
				if value.to_s.length > 0
					column_value_without_inheritance(column, issue, value)						
				else
					value=issue.find_ancestor_attribute			
				end
				
			else
				column_value_without_inheritance(column, issue, value)
			end
		end
				
		def csv_value_with_inheritance(column, obj, value)			
				
				case column.name			
				when :"cf_#{get_custom_field_id}"
					if value.to_s.length > 0
						csv_value_without_inheritance(column, obj, value)						
					else
						value=obj.find_ancestor_attribute					
						format_object(value, false)						
					end
				else
					csv_value_without_inheritance(column, obj, value)
				end
		
		end
		
		def query_to_csv_with_inheritance(items, query, options={})
			c = QueryColumn.new("cf_#{get_custom_field_id}")
			query.available_columns << c
			query_to_csv_without_inheritance(items, query, options={})
		end
	  end  
	end
end