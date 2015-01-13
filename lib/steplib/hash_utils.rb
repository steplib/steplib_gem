# monkeypatching a ABooleanValue type
#  so we can call .is_a? on true and false values
#  and get a positive answer for both for ABooleanValue type
module ABooleanValue; end
class TrueClass; include ABooleanValue; end
class FalseClass; include ABooleanValue; end

module Steplib
	class HashUtils
		class << self

			def deep_copy(hsh)
				return Marshal.load(Marshal.dump(hsh))
			end

			def whitelist(hsh, whitelist)
				return nil if hsh.nil?
				res_hash = {}
				whitelist.each do |whiteitm|
					res_hash[whiteitm] = hsh[whiteitm]
				end
				return res_hash
			end

			def check_required_attributes_and_types!(hash_to_check, attribute_type_array)
				attribute_type_array.each do |a_attribute_type_itm|
					attribute_key = a_attribute_type_itm[0]
					attribute_type = a_attribute_type_itm[1]
					#
					attr_value = hash_to_check[attribute_key]
					if attr_value.nil?
						raise "Attribute (#{attribute_key}) not found in hash"
					end
					unless attr_value.is_a? attribute_type
						raise "Attribute (#{attribute_key}) found, but it's type (#{attr_value.class}) doesn't match the required (#{attribute_type})"
					end
				end
				return true
			end

			#
			# Sets the provided default value for the specified
			#  key if the key is missing.
			# Defaults_arr is an array of {:key=>,:value=>} hashes
			# Doesn't do a copy of input hash, will inline-set
			#  the attributes / modify the input hash!
			def set_missing_defaults(hsh, defaults_arr)
				defaults_arr.each do |a_def|
					a_def_key = a_def[:key]
					a_def_value = a_def[:value]
					if hsh[a_def_key].nil?
						hsh[a_def_key] = a_def_value
					end
				end
				return hsh
			end
			# Deep-copy version
			# Returns a new hash, the original input hash will be kept unchanged!
			def set_missing_defaults_dcopy(in_hsh, defaults_arr)
				hsh = deep_copy(in_hsh)
				return set_missing_defaults(hsh, defaults_arr)
			end

			#
			# Copies the listed attributes from the copy_from hash
			#  to the copy_to hash in case the attribute is missing
			#  from copy_to hash.
			# Doesn't do a copy of input hash, will inline-set
			#  the attributes / modify the input hash!
			def copy_missing_attributes(hsh_copy_to, hsh_copy_from, attr_to_copy_list)
				attr_to_copy_list.each do |a_attr_to_copy|
					if hsh_copy_to[a_attr_to_copy].nil?
						hsh_copy_to[a_attr_to_copy] = hsh_copy_from[a_attr_to_copy]
					end
				end
				return hsh_copy_to
			end
			# Deep-copy version
			# Returns a new hash, the original input hash will be kept unchanged!
			def copy_missing_attributes_dcopy(in_hsh_copy_to, hsh_copy_from, attr_to_copy_list)
				hsh_copy_to = deep_copy(in_hsh_copy_to)
				return copy_missing_attributes(hsh_copy_to, hsh_copy_from, attr_to_copy_list)
			end

			#
			# Copies the listed attributes from the copy_from hash
			#  to the copy_to hash.
			# Doesn't do a copy of input hash, will inline-set
			#  the attributes / modify the input hash!
			def copy_attributes(hsh_copy_to, hsh_copy_from, attr_to_copy_list)
				attr_to_copy_list.each do |a_attr_to_copy|
					hsh_copy_to[a_attr_to_copy] = hsh_copy_from[a_attr_to_copy]
				end
				return hsh_copy_to
			end
			# Deep-copy version
			# Returns a new hash, the original input hash will be kept unchanged!
			def copy_attributes_dcopy(in_hsh_copy_to, hsh_copy_from, attr_to_copy_list)
				hsh_copy_to = deep_copy(in_hsh_copy_to)
				return copy_attributes(hsh_copy_to, hsh_copy_from, attr_to_copy_list)
			end

		end
	end
end