# frozen_string_literal: true

# @api private
# @since 0.25.1
class Qonfig::FileDataResolving::Resolver
  class << self
    # @param scheme [Symbol,String]
    # @param resolver_proc [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.25.1
    def add_resolver!(scheme, resolver_proc)
      @resolvers ||= {}
      @resolvers[scheme.to_sym] = resolver_proc
    end

    # @param scheme_name [Symbol,String]
    # @return [void]
    #
    # @api private
    # @since 0.25.1
    def set_default_resolver!(scheme_name)
      @default_resolver = resolvers.fetch(scheme_name.to_sym)
    end

    # @param file_path [String,Pathname]
    # @return [String]
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.25.1
    def resolve!(file_path, **options)
      scheme_name = URI(file_path.to_s).scheme
      scheme_name = scheme_name.to_sym unless scheme_name == nil
      resolver = resolvers[scheme_name] || default_resolver
      resolver.call(file_path.to_s.split('://').last, **options)
    end

    private

    # @return [Array<Proc>]
    #
    # @api private
    # @since 0.25.1
    attr_reader :resolvers

    # @return [Proc]
    #
    # @api private
    # @since 0.25.1
    attr_reader :default_resolver
  end
end
