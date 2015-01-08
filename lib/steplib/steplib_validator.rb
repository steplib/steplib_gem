require_relative 'hash_utils'

module Steplib
	class SteplibValidator
		class << self

			def validate_steplib!(steplib_data)
				expected_format_version = '0.9.0'

				if steplib_data['format_version'] != expected_format_version
					raise "Invalid format_version, expected (#{expected_format_version}) got (#{steplib_data['format_version']})"
				end

				HashUtils.check_required_attributes_and_types!(steplib_data, [
					['format_version', String],
					['generated_at_timestamp', Fixnum],
					['steplib_source', String],
					['steps', Hash]
					])

				steps_arr = steplib_data['steps']
				steps_arr.each do |a_step_id, a_step_data|
					validate_step!(a_step_data)
				end
			end

			def validate_step!(step_data)
				HashUtils.check_required_attributes_and_types!(step_data, [
					['id', String],
					['versions', Array],
					['latest', Hash]
					])

				# validate the versions
				step_version_datas = step_data['versions']
				step_version_datas.each do |a_step_version_data|
					validate_step_version!(a_step_version_data)
				end

				# also validate the 'latest' item
				validate_step_version!(step_data['latest'])
			end

			def validate_step_version!(step_version_data)
				HashUtils.check_required_attributes_and_types!(step_version_data, [
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

					HashUtils.check_required_attributes_and_types!(step_version_data['source'], [
						['git', String]
						])

					a_host_os_tags = step_version_data['host_os_tags']
					a_host_os_tags.each { |a_tag|
						raise "Invalid host-os-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_project_type_tags = step_version_data['project_type_tags']
					a_project_type_tags.each { |a_tag|
						raise "Invalid project-type-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_type_tags = step_version_data['type_tags']
					a_type_tags.each { |a_tag|
						raise "Invalid type-tag (#{a_tag}), not a String (class: #{a_tag.class})!" unless a_tag.is_a? String
					}

					a_inputs = step_version_data['inputs']
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

					a_outputs = step_version_data['outputs']
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