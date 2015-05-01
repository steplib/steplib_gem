require 'steplib/workflow_validator'

describe Steplib::WorkflowValidator do
	context 'with a valid data' do
		def create_valid_wf_data
			return {
				'format_version' => '0.9.0',
				'environments' => [{
					'title' => 'env title',
					'mapped_to' => 'ENV_VAR',
					'is_expand' => false,
					'value' => 'Value of the env var'
					}],
				'steps' => [{
					#
					# workflow format specific
					'position_in_workflow' => 0,
					'is_always_run' => false,
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
						}],
					'outputs' => [{
						'title' => 'output title',
						'description' => 'output description',
						'mapped_to' => 'OUT_ENV'
						}],
					'icon_url_256' => 'https://...',
					}],
					'meta' => {
						'data' => 'anything you like'
						}
				}
		end

		before(:each) do
			#
			@valid_workflow_data = create_valid_wf_data()
		end

		describe '#validate!' do
			it "should not raise an error" do
				expect{
					Steplib::WorkflowValidator.validate_workflow!(@valid_workflow_data)
					}.to_not raise_error
			end
		end

		describe '#whitelist_workflow' do
			it "should return the same data if there's no unsupported attribute" do
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).to eq(orig_data_copy)
			end

			it "should return the same a whitelisted workflow data - root attribute change" do
				# top level attribute
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				@valid_workflow_data['not_supported_attribute'] = 'not supported'
				whitelisted_data = Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).not_to eq(orig_data_copy)
				expect(whitelisted_data).to eq(orig_data_copy)
			end

			it "should return the same a whitelisted workflow data - environment attribute change" do
				# attribute in environments
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				@valid_workflow_data['environments'] = @valid_workflow_data['environments'].map do |itm|
					itm['not_supported_attribute'] = 'not supported'
					itm
				end
				whitelisted_data = Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).not_to eq(orig_data_copy)
				expect(whitelisted_data).to eq(orig_data_copy)
			end

			it "should return the same a whitelisted workflow data - step-version attribute change" do
				# attribute in steps
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				@valid_workflow_data['steps'] = @valid_workflow_data['steps'].map do |itm|
					itm['not_supported_attribute'] = 'not supported'
					itm
				end
				whitelisted_data = Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).not_to eq(orig_data_copy)
				expect(whitelisted_data).to eq(orig_data_copy)
			end

			it "should return the same a whitelisted workflow data - step-version:input attribute change" do
				# attribute in steps
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				@valid_workflow_data['steps'] = @valid_workflow_data['steps'].map do |a_step|
					a_step['inputs'] = a_step['inputs'].map do |itm|
						itm['not_supported_attribute'] = 'not supported'
						itm
					end
					a_step
				end
				whitelisted_data = Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).not_to eq(orig_data_copy)
				expect(whitelisted_data).to eq(orig_data_copy)
			end

			it "should return the same a whitelisted workflow data - step-version:output attribute change" do
				# attribute in steps
				orig_data_copy = Steplib::HashUtils.deep_copy(@valid_workflow_data)
				@valid_workflow_data['steps'] = @valid_workflow_data['steps'].map do |a_step|
					a_step['outputs'] = a_step['outputs'].map do |itm|
						itm['not_supported_attribute'] = 'not supported'
						itm
					end
					a_step
				end
				whitelisted_data = Steplib::WorkflowValidator.whitelist_workflow(@valid_workflow_data)
				expect(@valid_workflow_data).not_to eq(orig_data_copy)
				expect(whitelisted_data).to eq(orig_data_copy)
			end
		end
	end

	context 'with an invalid data' do
		describe '#validate!' do
			it "should raise an error" do
				expect{
					Steplib::WorkflowValidator.validate_workflow!({
						'format_version' => '0.8.0'
						})
					}.to raise_error
			end
		end
	end
end
