require 'steplib/steplib_validator'

describe Steplib::SteplibValidator do
	context 'with a valid steplib data' do
		before(:each) do
			latest_test_step_ver = {
				# auto generated
				'id' => 'step-id',
				'steplib_source' => 'https://github.com/steplib/steplib',
				'version_tag' => '1.0.0',
				# data from step.yml
				'name' => 'step name',
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
					}],
				'outputs' => [{
					'title' => 'output title',
					'description' => 'output description',
					'mapped_to' => 'OUT_ENV'
					}]
				}
			#
			@valid_steplib_data = {
				'format_version' => '0.9.0',
				'generated_at_timestamp' => 1420540014,
				'steplib_source' => 'https://github.com/steplib/steplib',
				'steps' => { 
					'step-id' => {
						'id' => 'step-id',
						'latest' => latest_test_step_ver,
						'versions' => [latest_test_step_ver]
						}
					}
				}
		end

		describe '#validate!' do
			it "should not raise an error" do
				expect{
					Steplib::SteplibValidator.validate_steplib!(@valid_steplib_data)
					}.to_not raise_error
			end
		end
	end

	context 'with an invalid steplib data' do
		describe '#validate!' do
			it "should raise an error" do
				expect{
					Steplib::SteplibValidator.validate_steplib!({
						'format_version' => '0.8.0'
						})
					}.to raise_error
			end
		end
	end
end