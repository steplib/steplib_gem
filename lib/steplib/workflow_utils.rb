require_relative 'hash_utils'

module Steplib
	class WorkflowUtils
		class << self

			def create_workflow_environment_item(title, mapped_to, value, is_expand)
				return {
					'title' => title.to_s,			 	# string
					'mapped_to' => mapped_to.to_s,		# string
					'value' => value.to_s,				# string
					'is_expand' => !!is_expand			# bool
				}
			end

			def create_workflow_base_template
				workflow_base_template = {
					'format_version' => '0.9.0',
					'environments' => [],
					'steps' => []
				}
				return workflow_base_template
			end

			def create_workflow_step_from_steplib_step(steplib_step, position_in_workflow)
				wf_step = HashUtils.deep_copy(steplib_step).merge({
					'position_in_workflow' => position_in_workflow.to_i,
					})
				return wf_step
			end

			def create_workflow_from_step_versions(steplib_step_versions, workflow_environments=[])
				workflow_data = create_workflow_base_template()
				workflow_data['steps'] = steplib_step_versions.map.with_index { |steplib_step_ver, idx|
					# return:
					create_workflow_step_from_steplib_step(steplib_step_ver, idx)
				}
				workflow_data['environments'] = workflow_environments
				return workflow_data
			end

		end
	end
end
