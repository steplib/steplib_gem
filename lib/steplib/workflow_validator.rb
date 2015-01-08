require_relative 'hash_utils'

module Steplib
	class WorkflowValidator
		class << self

			def validate_workflow!(workflow_data)
				expected_format_version = '0.9.0'
				if workflow_data['format_version'] != expected_format_version
					raise "Invalid format_version, expected (#{expected_format_version}) got (#{workflow_data['format_version']})"
				end

				HashUtils.check_required_attributes_and_types!(workflow_data, [
					['format_version', String],
					['environments', Array],
					['steps', Array]
					])

				envs_arr = workflow_data['environments']
				envs_arr.each do |a_env_data|
					validate_workflow_environment!(a_env_data)
				end

				steps_arr = workflow_data['steps']
				steps_arr.each do |a_step_data|
					validate_workflow_step!(a_step_data)
				end
			end

			def validate_workflow_environment!(env_item_data)
				HashUtils.check_required_attributes_and_types!(env_item_data, [
					['title', String],
					['mapped_to', String],
					['is_expand', ABooleanValue],
					['value', String],
					])
			end

			def validate_workflow_step!(workflow_step_data)
				HashUtils.check_required_attributes_and_types!(workflow_step_data, [
					['position_in_workflow', Fixnum],
					['is_always_run', ABooleanValue],
					# auto generated
					['id', String],
					['steplib_source', String],
					['version_tag', String],
					# data from step.yml
					['name', String],
					['description', String],
					['website', String],
					['fork_url', String],
					['source', Hash],
					['host_os_tags', Array],
					['project_type_tags', Array],
					['type_tags', Array],
					['is_requires_admin_user', ABooleanValue],
					['inputs', Array],
					['outputs', Array],
					])

					HashUtils.check_required_attributes_and_types!(workflow_step_data['source'], [
						['git', String]
						])

					a_host_os_tags = workflow_step_data['host_os_tags']
					a_host_os_tags.each { |a_tag|
						raise "Invalid host-os-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_project_type_tags = workflow_step_data['project_type_tags']
					a_project_type_tags.each { |a_tag|
						raise "Invalid project-type-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_type_tags = workflow_step_data['type_tags']
					a_type_tags.each { |a_tag|
						raise "Invalid type-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_inputs = workflow_step_data['inputs']
					a_inputs.each do |a_input_itm|
						HashUtils.check_required_attributes_and_types!(a_input_itm, [
						['title', String],
						['description', String],
						['mapped_to', String],
						['is_expand', ABooleanValue],
						['is_required', ABooleanValue],
						['value_options', Array],
						['value', String],
						['is_dont_change_value', ABooleanValue]
						])

						a_value_options = a_input_itm['value_options']
						a_value_options.each { |a_value_option|
							raise "Invalid value-option (#{a_value_option}), not a String (class: #{a_value_option.class})!" unless a_value_option.is_a? String
						}
					end

					a_outputs = workflow_step_data['outputs']
					a_outputs.each do |a_output_itm|
						HashUtils.check_required_attributes_and_types!(a_output_itm, [
						['title', String],
						['description', String],
						['mapped_to', String]
						])
					end
			end

		end
	end
end