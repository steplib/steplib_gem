require_relative 'hash_utils'
require_relative 'steplib_validator'

module Steplib
	class WorkflowValidator
		class << self

			def whitelist_workflow(workflow_data)
				whitelisted_data = HashUtils.whitelist(workflow_data,
					only_attributes(allowed_top_level_attributes_with_types())
					)

				whitelisted_data['environments'] = whitelisted_data['environments'].map do |an_env|
					whitelist_workflow_environment(an_env)
				end

				whitelisted_data['steps'] = whitelisted_data['steps'].map do |a_step_version|
					whitelist_workflow_step_version(a_step_version)
				end

				return whitelisted_data
			end

			def whitelist_workflow_environment(workflow_env_data)
				whitelisted_data = HashUtils.whitelist(workflow_env_data,
					only_attributes(allowed_environment_attributes_with_types())
					)
				return whitelisted_data
			end

			def whitelist_workflow_step_version(workflow_step_version_data)
				whitelisted_data = HashUtils.whitelist(workflow_step_version_data,
					only_attributes(allowed_step_version_attributes_with_types())
					)
				whitelisted_data['inputs'] = whitelisted_data['inputs'].map do |a_step_input|
					whitelist_workflow_step_version_input(a_step_input)
				end
				whitelisted_data['outputs'] = whitelisted_data['outputs'].map do |a_step_output|
					whitelist_workflow_step_version_output(a_step_output)
				end
				return whitelisted_data
			end

			def whitelist_workflow_step_version_input(workflow_step_version_input_data)
				whitelisted_data = HashUtils.whitelist(workflow_step_version_input_data,
					only_attributes(allowed_step_version_input_attributes_with_types())
					)
				return whitelisted_data
			end

			def whitelist_workflow_step_version_output(workflow_step_version_output_data)
				whitelisted_data = HashUtils.whitelist(workflow_step_version_output_data,
					only_attributes(allowed_step_version_output_attributes_with_types())
					)
				return whitelisted_data
			end

			def validate_workflow!(workflow_data)
				expected_format_version = '0.9.0'
				if workflow_data['format_version'] != expected_format_version
					raise "Invalid format_version, expected (#{expected_format_version}) got (#{workflow_data['format_version']})"
				end

				HashUtils.check_required_attributes_and_types!(workflow_data,
					required_top_level_attributes_with_types()
					)

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
				HashUtils.check_required_attributes_and_types!(env_item_data,
					required_environment_attributes_with_types())
			end

			def validate_workflow_step!(workflow_step_data)
				HashUtils.check_required_attributes_and_types!(workflow_step_data,
					required_step_version_attributes_with_types())

				# optional - can be nil
				workflow_step_data = HashUtils.set_missing_defaults(
					workflow_step_data,
					[{key: 'icon_url_256', value: nil}])

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
					HashUtils.check_required_attributes_and_types!(a_input_itm,
						required_step_version_input_attributes()
						)

					a_value_options = a_input_itm['value_options']
					a_value_options.each { |a_value_option|
						raise "Invalid value-option (#{a_value_option}), not a String (class: #{a_value_option.class})!" unless a_value_option.is_a? String
					}
				end

				a_outputs = workflow_step_data['outputs']
				a_outputs.each do |a_output_itm|
					HashUtils.check_required_attributes_and_types!(a_output_itm,
						required_step_version_output_attributes())
				end
			end


			#
			# required and allowed properties

			def required_top_level_attributes_with_types
				return [
					['format_version', String],
					['environments', Array],
					['steps', Array]
					]
			end

			def allowed_top_level_attributes_with_types
				return required_top_level_attributes_with_types().concat([
					['meta', Hash]
					])
			end

			def required_environment_attributes_with_types
				return [
					['title', String],
					['mapped_to', String],
					['is_expand', ABooleanValue],
					['value', String],
					]
			end

			def allowed_environment_attributes_with_types
				return required_environment_attributes_with_types()
			end

			def required_step_version_attributes_with_types
				return [
					['position_in_workflow', Fixnum],
					['is_always_run', ABooleanValue],
				].concat Steplib::SteplibValidator.required_step_version_properties_with_types()
			end

			def allowed_step_version_attributes_with_types
				return required_step_version_attributes_with_types().concat(
					Steplib::SteplibValidator.optional_step_version_properties_with_types()
				)
			end

			def required_step_version_input_attributes
				return Steplib::SteplibValidator.required_step_version_inputs_properties_with_types()
			end

			def required_step_version_output_attributes
				return Steplib::SteplibValidator.required_step_version_outputs_properties_with_types()
			end

			def allowed_step_version_input_attributes_with_types
				return Steplib::SteplibValidator.required_step_version_inputs_properties_with_types()
			end

			def allowed_step_version_output_attributes_with_types
				return Steplib::SteplibValidator.required_step_version_outputs_properties_with_types()
			end

			def only_attributes(attributes_list_with_types)
				return attributes_list_with_types.map { |e| e.first }
			end

		end
	end
end
