module Fib
  class PermissionsCollection
    # permissions: array for merge
    # permissions_map: hash for search
    attr_accessor :permissions, :permissions_map

    def initialize
      @permissions = []
      @permissions_map = {} # for merge
    end

    # find permission from collection
    def get(model, action)
      return nil unless @permissions_map.has_key? model
      return nil unless @permissions_map[model].has_key? action
      @permissions_map[model][action]
    end

    def set(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions_map[permission.model] ||= {}
      @permissions_map[permission.model][permission.action_name] = permission
      @permissions | [permission]
    end

    def mset(*permissions)
      permissions.flatten.each do |p|
        next unless permission.is_a?(Fib::Permission)
        set p
      end
    end

    def delete(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions_map[permission.model] ||= {}
      @permissions_map[permission.model].delete[permission.action_name]
      @permissions.delete permission
    end

    def add_permission(*options)
      if options.size < 2 && options.first.is_a?(Fib::Permission)
        set options.first
      else
        set Fib::Permission.new(*options)
      end
    end

    %w(+ - & |).each do |a|
      define_method a do |permissions|
        raise ParameterIsNotValid unless permissions.is_a? Fib::PermissionsCollection
        self.class.build_by_permissions(self.permissions.send(a, permissions.permissions))
      end
    end

    class << self
      def all_permissions
        @all_permissions
      end

      def build(&block)
        @all_permissions = new
        @all_permissions.instance_exec(&block)
      end

      def build_by_permissions(permissions)
        return unless permissions.is_a? Array
        new.tap { |p| p.mset permissions }
      end
    end
  end
end
