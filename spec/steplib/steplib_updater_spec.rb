require 'steplib/steplib_updater'
require 'steplib/steplib_validator'

describe Steplib::SteplibUpdater do
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
			'is_always_run' => false,
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
				}],
			'log_highlights' => [{
				'search_pattern' => '/a pattern/',
				'highlight_type' => 'error'
				}]
			}
		# only the most inner, 'leaf' properties missing,
		#  the main structure of this data is valid
		@steplib_step_version_with_missing_leafs = {
			# IDs of the step - to identify a step version globally
			'id' => 'step-id',
			'steplib_source' => 'https://github.com/steplib/steplib',
			'version_tag' => '1.0.0',
			#
			'name' => 'step name - can be changed by the user',
			'description' => 'step description',
			'website' => 'http://...',
			# 'fork_url' => 'http://...', # -> the 'website' url will be used
			# 'icon_url_256' => 'https://...',
			'source' => {
				'git' => 'http://...'
			},
			'host_os_tags' => ['osx-10.9'],
			# 'project_type_tags' => ['ios'],
			# 'type_tags' => ['test'],
			'is_requires_admin_user' => true,
			'inputs' => [{
				'title' => 'input title',
				# 'description' => 'input description',
				'mapped_to' => 'TEST_ENV',
				# 'is_expand' => false,
				# 'is_required' => false,
				# 'value_options' => ['val1', 'val2'],
				# 'value' => '(default)input value',
				# 'is_dont_change_value' => false
				}],
			'outputs' => [{
				'title' => 'output title',
				# 'description' => 'output description',
				'mapped_to' => 'OUT_ENV'
				}],
			'log_highlights' => [{
				'search_pattern' => '/a pattern/',
				'highlight_type' => 'error'
				}]
			}
	end

	describe 'example data validity check' do
		it "test data should be valid" do
			expect{
				Steplib::SteplibValidator.validate_step_version!(@steplib_step_version_with_two_inputs)
				}.to_not raise_error
		end
	end

	describe '#set_defaults_for_missing_properties_in_step_version' do
		it "should return the same data for a complete, valid steplib-step-version data" do
			data_copy = Steplib::HashUtils.deep_copy(@steplib_step_version_with_two_inputs)

			res_data = Steplib::SteplibUpdater.set_defaults_for_missing_properties_in_step_version(data_copy)
			expect(res_data).to eq(@steplib_step_version_with_two_inputs)
			expect(@steplib_step_version_with_two_inputs).to eq(data_copy)
		end

		it "should fill out the base format - this is the absolute minimum to make a valid steplib-step-version" do
			data_to_fill_out = Steplib::HashUtils.deep_copy(@steplib_step_version_with_missing_leafs)
			data_to_fill_out['inputs'] = nil
			data_to_fill_out['outputs'] = nil

			# it's not valid in itself / in it's current form
			expect{
				Steplib::SteplibValidator.validate_step_version!(data_to_fill_out)
				}.to raise_error

			res_data = Steplib::SteplibUpdater.set_defaults_for_missing_properties_in_step_version(data_to_fill_out)

			# but this should be valid after the default value setup
			expect{
				Steplib::SteplibValidator.validate_step_version!(res_data)
				}.to_not raise_error
		end

		it "should fill out the missing properties (on leaf properties) with valid default values, so that the steplib-step-version is valid" do
			# it's not valid in itself / in it's current form
			expect{
				Steplib::SteplibValidator.validate_step_version!(@steplib_step_version_with_missing_leafs)
				}.to raise_error

			res_data = Steplib::SteplibUpdater.set_defaults_for_missing_properties_in_step_version(@steplib_step_version_with_missing_leafs)

			# but this should be valid after the default value setup
			expect{
				Steplib::SteplibValidator.validate_step_version!(res_data)
				}.to_not raise_error
		end
	end
end
