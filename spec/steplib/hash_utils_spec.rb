require 'steplib/hash_utils'

describe Steplib::HashUtils do

	describe '#check_required_attributes_and_types!' do
		it "should not raise an error & should return true for a hash with all the required attributes and matching types" do
			hsh = {
				'string' => 'this is a string',
				'array' => [],
				'hash' => {},
				'fixnum' => 123,
				'bool' => false
			}
			required_attribs = [
				['string', String],
				['array', Array],
				['hash', Hash],
				['fixnum', Fixnum],
				#
				['bool', ABooleanValue],
			]
			ret_val = false
			expect{
				ret_val = Steplib::HashUtils.check_required_attributes_and_types!(hsh, required_attribs)
				}.to_not raise_error
			expect(ret_val).to be(true)
		end

		it "should raise an error for type missmatch" do
			hsh = {
				'type ok' => 'string type',
				'type missmatch' => 'not whats expected'
			}
			required_attribs = [
				['type ok', String],
				['type missmatch', Array]
			]
			expect{
				ret_val = Steplib::HashUtils.check_required_attributes_and_types!(hsh, required_attribs)
				}.to raise_error
		end

		it "should raise an error for missing required attribute" do
			hsh = {
				'can_be_found' => 'its here, indeed'
			}
			required_attribs = [
				['can_be_found', String],
				['missing_attrib', Array]
			]
			expect{
				ret_val = Steplib::HashUtils.check_required_attributes_and_types!(hsh, required_attribs)
				}.to raise_error
		end
	end

	describe '#set_missing_defaults_dcopy' do
		it "should return with a new hash, filled with the provided defaults for missing attributes" do
			hsh_src = {
				a: 1,
				b: '2'
			}

			filled_hsh = Steplib::HashUtils.set_missing_defaults_dcopy(hsh_src, [
				{key: :a, value: 2},
				{key: :c, value: 'c'}
				])

			# src should be kept as it was
			expect(hsh_src[:a]).to eq(1)
			expect(hsh_src[:b]).to eq('2')
			expect(hsh_src[:c]).to eq(nil)
			# filled hash's :a should remain the original value as it was not missing
			expect(filled_hsh[:a]).to eq(1)
			expect(filled_hsh[:b]).to eq('2')
			# and should contain the previously missing :c
			expect(filled_hsh[:c]).to eq('c')
		end
	end

	describe '#copy_missing_defaults_dcopy' do
		it "should return with a new hash, filled with the values copied from copy_from hash for missing attributes" do
			hsh_copy_to = {
				a: 1,
				b: 2
			}
			hsh_copy_from = {
				a: 'a',
				b: 'b',
				c: 'c',
				d: 'd'
			}
			copy_these = [:a, :c]

			filled_hsh = Steplib::HashUtils.copy_missing_defaults_dcopy(
				hsh_copy_to,
				hsh_copy_from,
				copy_these)

			# src should be kept as it was
			expect(hsh_copy_to[:a]).to eq(1)
			expect(hsh_copy_to[:b]).to eq(2)
			expect(hsh_copy_to[:c]).to eq(nil)
			expect(hsh_copy_to[:d]).to eq(nil)

			# filled hash's :a should remain the original value as it was not missing
			expect(filled_hsh[:a]).to eq(1)
			expect(filled_hsh[:b]).to eq(2)
			# and should contain the previously missing :c
			expect(filled_hsh[:c]).to eq('c')
			# :d should not be copied as it was not specified
			expect(filled_hsh[:d]).to eq(nil)
		end
	end

	describe '#copy_attributes_dcopy' do
		it "should return with a new hash, with the values copied from copy_from hash, even for non missing attributes!" do
			hsh_copy_to = {
				a: 1,
				b: 2
			}
			hsh_copy_from = {
				a: 'a',
				b: 'b',
				c: 'c',
				d: 'd'
			}
			copy_these = [:a, :c]

			filled_hsh = Steplib::HashUtils.copy_attributes_dcopy(
				hsh_copy_to,
				hsh_copy_from,
				copy_these)

			# src should be kept as it was
			expect(hsh_copy_to[:a]).to eq(1)
			expect(hsh_copy_to[:b]).to eq(2)
			expect(hsh_copy_to[:c]).to eq(nil)
			expect(hsh_copy_to[:d]).to eq(nil)

			# filled hash's :a should be changed / copied, unlike in the 'copy_missing_defaults_dcopy' spec
			expect(filled_hsh[:a]).to eq('a')
			expect(filled_hsh[:b]).to eq(2)
			# and should contain the previously missing :c
			expect(filled_hsh[:c]).to eq('c')
			# :d should not be copied as it was not specified
			expect(filled_hsh[:d]).to eq(nil)
		end

		it "should copy nested hashes" do
			hsh_copy_to = {
				person: {
					name: 'name 1',
					age: 1
				}
			}
			hsh_copy_from = {
				person: {
					name: 'name 2',
					age: 2
				}
			}
			copy_these = [:person]

			filled_hsh = Steplib::HashUtils.copy_attributes_dcopy(
				hsh_copy_to,
				hsh_copy_from,
				copy_these)

			expect(hsh_copy_to).to eq({
				person: {
					name: 'name 1',
					age: 1
					}
				})

			expect(filled_hsh).to eq({
				person: {
					name: 'name 2',
					age: 2
					}
				})
		end
	end

end