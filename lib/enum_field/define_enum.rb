# encoding: utf-8
module EnumField
  module DefineEnum
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend,  ClassMethods
    end

    module ClassMethods
      def self.extended(base)
        base.class_eval do
          attr_reader :id, :name
        end
      end

      def define_enum(&block)
        @enum_builder ||= EnumField::Builder.new(self)
        yield @enum_builder

        [:all, :names, :find_by_id, :find, :first, :last].each do |method|
          instance_eval <<-END
            def #{method}(*args, &block)
              @enum_builder.send(:#{method}, *args, &block)
            end
          END
        end
      end
    end

    module InstanceMethods
    end
  end
end
