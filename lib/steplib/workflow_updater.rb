require_relative 'steplib_validator'
require_relative 'hash_utils'

module Steplib
	class WorkflowUpdater
		class << self

			#
			# of course this can only fill-out properties
			#  which have a pre-defined valid default value
			def set_defaults_for_missing_properties_in_workflow(workflow_data)
				workflow_data = HashUtils.set_missing_defaults(workflow_data, [
					# main arrays
					{key: 'environments', value: []},
					{key: 'steps', value: []},
					])
				#
				# environments
				workflow_data['environments'] = workflow_data['environments'].map { |an_env|
					an_env = HashUtils.set_missing_defaults(an_env, [
						{key: 'title', value: ''},
						{key: 'is_expand', value: true},
						])
					# return:
					an_env
				}
				#
				# steps
				workflow_data['steps'] = workflow_data['steps'].map { |a_step|
					a_step = set_defaults_for_missing_properties_in_workflow_step(a_step)
					# return:
					a_step
				}
				return workflow_data
			end

			#
			# similar to \a set_defaults_for_missing_properties_in_workflow
			#  but for a single workflow-step
			def set_defaults_for_missing_properties_in_workflow_step(workflow_step_data)
				workflow_step_data = HashUtils.set_missing_defaults(workflow_step_data, [
					{key: 'name', value: ''},
					{key: 'description', value: ''},
					{key: 'icon_url_256', value: nil},
					{key: 'project_type_tags', value: []},
					{key: 'type_tags', value: []},
					# main arrays
					{key: 'inputs', value: []},
					{key: 'outputs', value: []},
					])
				workflow_step_data['inputs'] = workflow_step_data['inputs'].map { |a_step_inp|
					a_step_inp = HashUtils.set_missing_defaults(a_step_inp, [
						{key: 'title', value: ''},
						{key: 'description', value: ''},
						{key: 'is_expand', value: true},
						{key: 'is_required', value: false},
						{key: 'value_options', value: []},
						{key: 'is_dont_change_value', value: false},
						])
					# return:
					a_step_inp
				}
				workflow_step_data['outputs'] = workflow_step_data['outputs'].map { |a_step_output|
					a_step_output = HashUtils.set_missing_defaults(a_step_output, [
						{key: 'description', value: ''}
						])
					# return:
					a_step_output
				}
				return workflow_step_data
			end

			#
			# The input steplib_step_version have to be a valid step-version!
			# The input workflow_step is not copied, modified in-inline!
			# Also: inputs which can't be found in the steplib-step-version
			#  WILL BE REMOVED and inputs which can be found in the steplib-step-version
			#  but not in the workflow-step inputs WILL BE ADDED
			# Because of the potential destructive nature of this method you
			#  should use it carefully and you can expect an exception/error raised for:
			#  * steplib-step-version is not valid
			#  * steplib-step-version's version_tag doesn't match the workflow_step's version_tag
			#  * missing 'version_tag' in workflow_step
			def update_workflow_step_with_steplib_step_version!(workflow_step, steplib_step_version)
				#
				SteplibValidator.validate_step_version!(steplib_step_version)
				raise "Missing 'version_tag'" if workflow_step['version_tag'].nil?
				if workflow_step['version_tag'] != steplib_step_version['version_tag']
					raise "Workflow-step 'version_tag' doesn't match the steplib-step-version's"
				end
				#
				# copy all except the ones which are used for identifying the input inside a step(-version):
				# * steplib_source
				# * id
				# * version_tag
				#
				# copy no-matter-what:
				workflow_step = HashUtils.copy_attributes(
					workflow_step,
					steplib_step_version,
					['description', 'website', 'fork_url', 'source', 'host_os_tags',
						'project_type_tags', 'type_tags', 'is_requires_admin_user',
						'icon_url_256']
					)
				#
				# copy only if missing
				#  see "@WorkflowUserMod" in the steplib format spec for more information
				workflow_step = HashUtils.copy_missing_attributes(
					workflow_step,
					steplib_step_version,
					['name']
					)

				# update inputs and remove the ones which can't be
				#  found in the steplib step version's inputs
				#  and add the missing ones
				steplib_step_version_inputs = steplib_step_version['inputs']
				workflow_step['inputs'] = workflow_step['inputs'].map { |a_wf_step_inp|
					# search for the same input in the steplib-step-version
					related_steplib_input = steplib_step_version_inputs.find do |possible_inp|
						if possible_inp['mapped_to'] == a_wf_step_inp['mapped_to']
							true
						else
							false
						end
					end
					if related_steplib_input.nil?
						# not found - remove (w/ .compact)
						# return:
						nil
					else
						# copy all except the ones which are used for identifying the input inside a step(-version):
						#  * mapped_to
						# copy no matter what
						a_wf_step_inp = HashUtils.copy_attributes(
							a_wf_step_inp,
							related_steplib_input,
							['title', 'description',
								'is_required', 'value_options', 'is_dont_change_value']
							)
						# copy only if missing
						#  see "@WorkflowUserMod" in the steplib format spec for more information
						a_wf_step_inp = HashUtils.copy_missing_attributes(
							a_wf_step_inp,
							related_steplib_input,
							['value', 'is_expand']
							)
						# return:
						a_wf_step_inp
					end
				}.compact # .compact removes nil elements
				# add missing ones
				wf_step_inputs = workflow_step['inputs']
				missing_inputs = steplib_step_version_inputs.select { |a_steplib_input|
					wf_step_input = wf_step_inputs.find do |a_wf_inp|
						if a_wf_inp['mapped_to'] == a_steplib_input['mapped_to']
							true
						else
							false
						end
					end
					# add, if not found
					# return:
					wf_step_input.nil?
				}
				workflow_step['inputs'] = wf_step_inputs.concat(missing_inputs)

				# update outputs to match the steplib-step-version's
				#  output list
				workflow_step['outputs'] = Steplib::HashUtils.deep_copy(steplib_step_version['outputs'])

				return workflow_step
			end

		end
	end
end