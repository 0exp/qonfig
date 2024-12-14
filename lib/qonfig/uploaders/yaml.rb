# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::YAML < Qonfig::Uploaders::File
  # @api private
  # @since 0.11.0
  class YAMLRepresenter < Psych::Visitors::YAMLTree
    # Needed for using the '~' symbol used for null value representation in YAML files
    # (instead of space symbol (' ')) (see psych/lib/psych/visitors/yaml_tree.rb)
    #
    # @param object [Any]
    # @return [Any]
    #
    # @api private
    # @since 0.11.0
    def visit_NilClass(object) # rubocop:disable Naming/MethodName
      @emitter.scalar('~', nil, 'tag:yaml.org,2002:null', true, false, Psych::Nodes::Scalar::ANY)
    end
  end

  # @return [Hash<Symbol,Any>]
  #
  # @api private
  # @since 0.11.0
  DEFAULT_OPTIONS = {
    indentation: 2,
    line_width: -1,
    canonical: false,
    header: false,
    symbolize_keys: false
  }.freeze

  # @return [Proc]
  #
  # @api private
  # @since 0.11.0
  KEY_SYMBOLIZER = lambda(&:to_sym).freeze

  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol,Any>]
    # @param value_processor [Block]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings, options, &value_processor)
      settings_hash_opts = hash_representation_options(options, &value_processor)
      settings_hash = settings.__to_hash__(**settings_hash_opts)
      to_yaml_string(settings_hash, options)
    end

    # @param options [Hash<Symbol|String,Any>]
    # @param value_processor [Block]
    # @return [Hash]
    #
    # @api private
    # @since 0.11.0
    def hash_representation_options(options, &value_processor)
      {}.tap do |representation_opts|
        # NOTE: this case/when with the same logic is only used for better code readbility
        # rubocop:disable Lint/DuplicateBranch
        case
        # NOTE: options has :symbolize_keys key
        when options.key?(:symbolize_keys) && !!options[:symbolize_keys]
          representation_opts[:transform_key] = KEY_SYMBOLIZER
        # NOTE: options does not have :symbolize_keys key
        when !options.key?(:symbolize_keys) && DEFAULT_OPTIONS[:symbolize_keys]
          # :nocov:
          representation_opts[:transform_key] = KEY_SYMBOLIZER
          # :nocov:
        end
        # rubocop:enable Lint/DuplicateBranch

        # NOTE: provide value transformer
        if block_given?
          representation_opts[:transform_value] = value_processor
        end
      end
    end

    # @param settings_hash [Hash<String|Symbol,Any>]
    # @param yaml_options [Hash<Symbol,Any>]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def to_yaml_string(settings_hash, yaml_options)
      representer = YAMLRepresenter.create(yaml_options)
      representer << settings_hash
      representer.tree.yaml(nil, yaml_options)
    end
  end
end
