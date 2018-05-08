module RbLatex
  class MetaInfo

    ATTRS = %i(title creator page_progression_direction)

    ATTRS.each do |name|
      define_method(name) do
        @info[name]
      end
      name_eq = "#{name}=".to_sym
      define_method(name_eq) do |val|
        @info[name] = val
      end
    end

    def initialize
      @info = Hash.new
    end

    def date=(time)
      if time.kind_of? String
        @info[:date] = Time.parse(time)
      else
        @info[:date] = time
      end
    end

    def date
      @info[:date]
    end

    def date_to_s
      date_format(@info[:date])
    end

    def lastmodified=(time)
      if time.kind_of? String
        @info[:lastmodified] = Time.parse(time)
      else
        @info[:lastmodified] = time
      end
    end

    def lastmodified
      @info[:lastmodified]
    end

    def lastmodified_to_s
      date_format(@info[:lastmodified])
    end

    def all
      @info
    end

    def date_format(time)
      time.strftime("%Y年%-m月%-d日")
    end

    def add_creator(name, role)
      if !@info[:creator]
        !@info[:creator] = Hash.new
      end
      @info[:creator][role] = name
    end
  end
end
