require 'steplib/workflow_updater'

describe Steplib::WorkflowUpdater do
	before(:each) do
		@steplib_step_version_with_two_inputs = {
			#
			# steplib format specific
			## auto generated
			'id' => 'step-id',
			'steplib_source' => 'https://github.com/steplib/steplib',
			'version_tag' => '1.0.0',
			## data from step.yml
			'name' => 'step name - can be changed by the user',
			'description' => 'step description',
			'website' => 'http://...',
			'fork_url' => 'http://...',
			'icon_url_256' => 'https://...',
			'source' => {
				'git' => 'http://...'
			},
			'host_os_tags' => ['osx-10.9'],
			'project_type_tags' => ['ios'],
			'type_tags' => ['test'],
			'is_requires_admin_user' => true,
			'inputs' => [{
				'title' => 'input title',
				'description' => 'input description',
				'mapped_to' => 'TEST_ENV',
				'is_expand' => false,
				'is_required' => false,
				'value_options' => ['val1', 'val2'],
				'value' => 'input value',
				'is_dont_change_value' => false
				}, {
				'title' => 'input title 2',
				'description' => 'input description 2',
				'mapped_to' => 'TEST_ENV_2',
				'is_expand' => false,
				'is_required' => false,
				'value_options' => ['val1', 'val2'],
				'value' => 'input value',
				'is_dont_change_value' => false
				}],
			'outputs' => [{
				'title' => 'output title',
				'description' => 'output description',
				'mapped_to' => 'OUT_ENV'
				}]
			}
	end

	describe '#inject_missing_default_values_from_step_version' do

		it "should return the same data for a valid workflow data" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_step = steplib_step_version.merge({
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				})
			

			res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
				workflow_step,
				steplib_step_version)
			expect(res_data).to eq(workflow_step)
		end

		it "should raise an error for an invalid input step-data" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_step = steplib_step_version.merge({
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				})
			
			steplib_step_version['id'] = nil

			expect{
				res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
					workflow_step,
					steplib_step_version)
				}.to raise_error
		end

		it "should raise an error if version_tag is missing from the workflow-step or if it doesn't match the steplib step's version_tag" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_step = steplib_step_version.merge({
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				})
			version_tag_backup = workflow_step['version_tag']

			# missing version_tag
			workflow_step['version_tag'] = nil
			expect{
				res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
					workflow_step,
					steplib_step_version)
				}.to raise_error

			# put back backup - should be ok
			workflow_step['version_tag'] = version_tag_backup
			expect{
				res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
					workflow_step,
					steplib_step_version)
				}.to_not raise_error

			# now change it to a non matching one
			workflow_step['version_tag'] = '0.0.0-no-match'
			expect{
				res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
					workflow_step,
					steplib_step_version)
				}.to raise_error
		end

		it "should append missing input" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_specific_data = {
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				}
			workflow_step = Steplib::HashUtils.deep_copy(steplib_step_version).merge(workflow_specific_data)
			# keep only the first input in the workflow
			workflow_step['inputs'] = [workflow_step['inputs'].first]
			
			res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
				workflow_step,
				steplib_step_version)
			# the result should match the steplib-step-version
			#  merged with the workflow specific data
			expect(res_data).to eq(steplib_step_version.merge(workflow_specific_data))
			# [!] it also changes the input workflow_step, not just the result
			expect(res_data).to eq(workflow_step)
		end

		it "should remove unnecessary input (which is no more present in the steplib step version)" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_specific_data = {
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				}
			workflow_step = Steplib::HashUtils.deep_copy(steplib_step_version).merge(workflow_specific_data)
			# add an additional input - which should be removed
			#  to match the steplib step's input list
			workflow_step['inputs'] = workflow_step['inputs'].push({
				'title' => 'input title 3',
				'description' => 'input description 3',
				'mapped_to' => 'TEST_ENV_3',
				'is_expand' => false,
				'is_required' => false,
				'value_options' => ['val1', 'val2'],
				'value' => 'input value 3',
				'is_dont_change_value' => false
				})
			
			res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
				workflow_step,
				steplib_step_version)
			# the result should match the steplib-step-version
			#  merged with the workflow specific data
			expect(res_data).to eq(steplib_step_version.merge(workflow_specific_data))
			# [!] it also changes the input workflow_step, not just the result
			expect(res_data).to eq(workflow_step)
		end

		it "should use the provided steplib step version's outputs (replace the workflow step's)" do
			steplib_step_version = @steplib_step_version_with_two_inputs
			workflow_specific_data = {
				#
				# workflow format specific
				'position_in_workflow' => 0,
				'is_always_run' => false,
				}

			# add an additional output
			workflow_step = Steplib::HashUtils.deep_copy(steplib_step_version).merge(workflow_specific_data)
			workflow_step['outputs'] = workflow_step['outputs'].push({
				'title' => 'output title',
				'description' => 'output description',
				'mapped_to' => 'OUT_ENV'
				})
			
			res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
				workflow_step,
				steplib_step_version)
			# the result should match the steplib-step-version
			#  merged with the workflow specific data
			expect(res_data).to eq(steplib_step_version.merge(workflow_specific_data))
			# [!] it also changes the input workflow_step, not just the result
			expect(res_data).to eq(workflow_step)


			# remove the outputs from the workflow
			workflow_step = Steplib::HashUtils.deep_copy(steplib_step_version).merge(workflow_specific_data)
			workflow_step['outputs'] = []
			
			res_data = Steplib::WorkflowUpdater.update_workflow_step_with_steplib_step_version!(
				workflow_step,
				steplib_step_version)
			# the result should match the steplib-step-version
			#  merged with the workflow specific data
			expect(res_data).to eq(steplib_step_version.merge(workflow_specific_data))
			# [!] it also changes the input workflow_step, not just the result
			expect(res_data).to eq(workflow_step)
		end

	end
end