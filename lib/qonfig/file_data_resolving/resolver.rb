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
      self.resolvers ||= {}
      resolvers[scheme.to_sym] = resolver_proc
    end

    # @param scheme_name [Symbol,String]
    # @return [void]
    #
    # @api private
    # @since 0.25.1
    def set_default_resolver!(scheme_name)
      self.default_resolver = resolvers[scheme_name.to_sym]
    end

    # @param file_path [String,Pathname]
    # @return [String]
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.25.1
    def resolve!(file_path)
      scheme_name = URI(file_path.to_s).scheme&.to_sym
      resolver = resolvers[scheme_name] || default_resolver
      resolver.call(file_path.to_s.split('://').last)
    end

    private

    # @return [Array<Proc>]
    #
    # @api private
    # @since 0.25.1
    attr_accessor :resolvers

    # @return [Proc]
    #
    # @api private
    # @since 0.25.1
    attr_accessor :default_resolver
  end
end
