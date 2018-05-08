module RbLatex
  class ItemList
    def initialize()
      @items = Hash.nwe
    end

    def add_item(filename, content)
      @items[filename] = content
    end

    def generate(dir)
      @items.each do |filename, content|
        path = File.join(dir, filename)
        File.write(path, content)
      end
    end
  end
end
