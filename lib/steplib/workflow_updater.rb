require_relative 'steplib_validator'
require_relative 'hash_utils'

module Steplib
	class WorkflowUpdater
		class << self

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
				# copy all except:
				# * name
				# * version_tag
				workflow_step = HashUtils.copy_attributes(
					workflow_step,
					steplib_step_version,
					[
						'id', 'steplib_source', 'description',
						'website', 'fork_url', 'source', 'host_os_tags',
						'project_type_tags', 'type_tags', 'is_requires_admin_user',
						'icon_url_256'
					]
					)

				# update inputs and remove the ones which can't be
				#  found in the steplib step version's inputs
				#  and add the missing ones
				# update except:
				#  * mapped_to
				#  * value
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
						a_wf_step_inp = HashUtils.copy_attributes(
							a_wf_step_inp,
							related_steplib_input,
							['title', 'description', 'is_expand',
								'is_required', 'value_options', 'is_dont_change_value']
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