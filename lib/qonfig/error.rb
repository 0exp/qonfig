# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @see Qonfig::Settings
  # @see Qonfig::DSL
  #
  # @api public
  # @since 0.1.0
  ArgumentError = Class.new(Error)

  # @see Qonfig::Settings
  #
  # @api public
  # @since 0.1.0
  UnknownSettingError = Class.new(Error)

  # @see Qonfig::Settings
  #
  # @api public
  # @since 0.1.0
  FrozenSettingsError = begin
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0')
      Class.new(::FrozenError)
    else
      Class.new(::RuntimeError)
    end
  end

  # @see Qonfig::Commands::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  IncompatibleYAMLError = Class.new(Error)
end
