module RbLatex
  class ItemList
    def initialize()
      @items = Hash.new
    end

    def add_item(filename, content)
      @items[filename] = content
    end

    def filenames
      @items.keys
    end

    def generate(dir)
      @items.each do |filename, content|
        path = File.join(dir, filename)
        File.write(path, content)
      end
    end
  end
end
