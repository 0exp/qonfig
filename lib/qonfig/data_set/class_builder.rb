# frozen_string_literal: true

module Qonfig
  class DataSet
    # @api private
    # @since 0.2.0
    module ClassBuilder
      class << self
        # @param hash [Hash]
        # @return [Class<Qonfig::DataSet>]
        #
        # @see Qonfig::DataSet
        # @see Qonfig::DSL
        #
        # @api private
        # @since 0.2.0
        def build_from_hash(hash)
          Class.new(Qonfig::DataSet).tap do |data_set_klass|
            hash.each_pair do |key, value|
              if value.is_a?(Hash)
                sub_data_set_klass = build_from_hash(value)

                data_set_klass.setting(key) { compose sub_data_set_klass }
              else
                data_set_klass.setting key, value
              end
            end
          end
        end
      end
    end
  end
end
