# encoding: utf-8
module EnumField
  class Builder
    ENABLED_OPTIONS = [:object, :id, :is_freeze].freeze

    def initialize(target)
      @target = target
      @next_id = 0
      @id2obj = {}
      @name2obj = {}
      @sorted = []
      @default_options = { is_freeze: true }
    end

    def member(name, options = {})
      options = @default_options.merge(options)
      obj, candidate_id = process_options(options)
      assign_id(obj, candidate_id)
      assign_name(obj, name)
      define_in_meta(name) { obj }
      save(name, obj)
      obj.freeze if options[:is_freeze] == true
    end

    def all
      @sorted.dup
    end

    def names
      @name2obj.keys
    end

    def find(id)
      find_by_id(id) or raise EnumField::ObjectNotFound
    end

    def find_by_id(id)
      @id2obj[id.to_i]
    end

    def first; @sorted.first; end
    def last; @sorted.last; end

    private

    def define_in_meta(name, &block)
      metaclass = class << @target; self; end
      metaclass.send(:define_method, name, &block)
    end

    def assign_id(obj, candidate_id)
      id = new_id(candidate_id)
      obj.instance_variable_set(:@id, id)
    end

    def assign_name(obj, name)
      obj.instance_variable_set(:@name, name)
    end

    def new_id(candidate)
      validate_candidate_id(candidate)
      candidate || find_next_id
    end

    def validate_candidate_id(id)
      raise EnumField::InvalidId.new(id) unless id.nil? || id.is_a?(Integer) && id > 0
      raise EnumField::RepeatedId.new(id) if @id2obj.has_key?(id)
    end

    def find_next_id
      @next_id += 1 while @id2obj.has_key?(@next_id) || @next_id <= 0
      @next_id
    end

    def process_options(options)
      raise EnumField::InvalidOptions if (options.keys - ENABLED_OPTIONS).any?
      [options[:object] || @target.new, options[:id]]
    end

    def save(name, obj)
      @id2obj[obj.id] = obj
      @sorted << obj
      @name2obj[name] = obj
    end
  end
end
