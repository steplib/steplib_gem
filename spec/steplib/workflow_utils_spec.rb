require 'steplib/workflow_utils'

describe Steplib::WorkflowUtils do

	before(:each) do
		@valid_steplib_step_version_1 = {
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
			'is_always_run' => true,
			'inputs' => [{
				'title' => 'input title',
				'description' => 'input description',
				'mapped_to' => 'TEST_ENV',
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
		#
		@valid_steplib_step_version_2 = Steplib::HashUtils.deep_copy(@valid_steplib_step_version_1)
		@valid_steplib_step_version_2['id'] = 'id-2'
		@valid_steplib_step_version_2['name'] = 'name 2'
	end

	describe '#create_workflow_environment_item' do
		it "should return a valid environment item" do
			expected_hsh = {
				'title' => 'title of env',
				'mapped_to' => 'MAPPED_TO_ENV',
				'value' => 'env value',
				'is_expand' => true
			}

			wf_env_itm = Steplib::WorkflowUtils.create_workflow_environment_item(
				'title of env',
				'MAPPED_TO_ENV',
				'env value',
				true)
			expect(wf_env_itm).to eq(expected_hsh)
			# should be valid
			expect{
				Steplib::WorkflowValidator.validate_workflow_environment!(wf_env_itm)
				}.to_not raise_error
		end
	end

	describe '#create_workflow_base_template' do
		it "should return a base, valid, workflow template hash" do
			expected_hsh = {
				'format_version' => '0.9.0',
				'environments' => [],
				'steps' => []
			}

			wf_template = Steplib::WorkflowUtils.create_workflow_base_template()
			expect(wf_template).to eq(expected_hsh)
			# should be valid
			expect{
				Steplib::WorkflowValidator.validate_workflow!(wf_template)
				}.to_not raise_error
		end
	end

	describe '#create_workflow_step_from_steplib_step' do
		it "should return a valid Workflow step based on the input step" do
			wf_step = Steplib::WorkflowUtils.create_workflow_step_from_steplib_step(
				@valid_steplib_step_version_1,
				0)
			# should be valid
			expect{
				Steplib::WorkflowValidator.validate_workflow_step!(wf_step)
				}.to_not raise_error
		end
	end

	describe '#create_workflow_from_step_versions' do
		it "should return a valid Workflow, with the included steps and envs" do
			steplib_step_verions = [@valid_steplib_step_version_1, @valid_steplib_step_version_2]
			#
			wf_env_itm_1 = Steplib::WorkflowUtils.create_workflow_environment_item(
				'title of env',
				'MAPPED_TO_ENV',
				'env value',
				true)
			wf_envs = [wf_env_itm_1]
			#
			wf_data = Steplib::WorkflowUtils.create_workflow_from_step_versions(
				steplib_step_verions,
				wf_envs)
			# should be valid
			expect{
				Steplib::WorkflowValidator.validate_workflow!(wf_data)
				}.to_not raise_error
		end
	end

end
