require_relative 'hash_utils'

module Steplib
	class SteplibUpdater
		class << self

			#
			# of course this can only fill-out properties
			#  which have a pre-defined valid default value
			def set_defaults_for_missing_properties_in_step_version(step_version_data)
				step_version_data = HashUtils.set_missing_defaults(step_version_data, [
					{key: 'fork_url', value: step_version_data['website']},
					{key: 'icon_url_256', value: nil},
					{key: 'is_always_run', value: false},
					{key: 'project_type_tags', value: []},
					{key: 'type_tags', value: []},
					{key: 'inputs', value: []},
					{key: 'outputs', value: []},
					{key: 'log_highlights', value: []},
					])
				#
				# inputs
				step_version_data['inputs'] = step_version_data['inputs'].map { |a_step_inp|
					a_step_inp = HashUtils.set_missing_defaults(a_step_inp, [
						{key: 'description', value: ''},
						{key: 'is_expand', value: true},
						{key: 'is_required', value: false},
						{key: 'value_options', value: []},
						{key: 'value', value: ''},
						{key: 'is_dont_change_value', value: false},
						])
					# return:
					a_step_inp
				}
				#
				# outputs
				step_version_data['outputs'] = step_version_data['outputs'].map { |a_step_output|
					a_step_output = HashUtils.set_missing_defaults(a_step_output, [
						{key: 'description', value: ''}
						])
					# return:
					a_step_output
				}
				return step_version_data
			end

		end
	end
end
