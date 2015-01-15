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

			def whitelist_step_version(step_version_data)
				raise "Input step_version_data hash is nil" if step_version_data.nil?

				base_prop_whitelist = required_step_version_properties_with_types().map { |e| e.first }
				base_prop_whitelist = base_prop_whitelist.concat( optional_step_version_properties() )
				step_version_data = HashUtils.whitelist(step_version_data, base_prop_whitelist)
				# source
				step_version_data['source'] = HashUtils.whitelist(
					step_version_data['source'],
					required_step_version_source_properties_with_types().map { |e| e.first })
				# inputs
				step_version_data['inputs'] = step_version_data['inputs'].map do |a_step_input|
					HashUtils.whitelist(
						a_step_input,
						required_step_version_inputs_properties_with_types().map { |e| e.first })
				end
				# outputs
				step_version_data['outputs'] = step_version_data['outputs'].map do |a_step_output|
					HashUtils.whitelist(
						a_step_output,
						required_step_version_outputs_properties_with_types().map { |e| e.first })
				end
				return step_version_data
			end

			def required_step_version_properties_with_types
				return [
					# auto-generated IDs
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
					]
			end

			def optional_step_version_properties
				return ['icon_url_256']
			end

			def required_step_version_source_properties_with_types
				return [ ['git', String] ]
			end

			def required_step_version_inputs_properties_with_types
				return [
					['title', String],
					['description', String],
					['mapped_to', String],
					['is_expand', ABooleanValue],
					['is_required', ABooleanValue],
					['value_options', Array],
					['value', String],
					['is_dont_change_value', ABooleanValue]
					]
			end

			def required_step_version_outputs_properties_with_types
				return [
					['title', String],
					['description', String],
					['mapped_to', String]
					]
			end

			def validate_step_version!(step_version_data)
				# whitelist
				step_version_data = whitelist_step_version(step_version_data)
				# check/validate
				HashUtils.check_required_attributes_and_types!(
					step_version_data,
					required_step_version_properties_with_types()
					)

				# optional - can be nil
				step_version_data = HashUtils.set_missing_defaults(
					step_version_data,
					[{key: 'icon_url_256', value: nil}])

				HashUtils.check_required_attributes_and_types!(
					step_version_data['source'],
					required_step_version_source_properties_with_types()
					)

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
					HashUtils.check_required_attributes_and_types!(
						a_input_itm,
						required_step_version_inputs_properties_with_types()
						)

					a_value_options = a_input_itm['value_options']
					a_value_options.each { |a_value_option|
						raise "Invalid value-option (#{a_value_option}), not a String (class: #{a_value_option.class})!" unless a_value_option.is_a? String
					}
				end

				a_outputs = step_version_data['outputs']
				a_outputs.each do |a_output_itm|
					HashUtils.check_required_attributes_and_types!(
						a_output_itm,
						required_step_version_outputs_properties_with_types()
						)
				end
			end

		end
	end
end