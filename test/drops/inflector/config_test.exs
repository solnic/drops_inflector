defmodule Drops.Inflector.ConfigTest do
  use ExUnit.Case
  doctest Drops.Inflector

  describe "custom inflector" do
    defmodule Test.Inflector do
      use Drops.Inflector,
        plural: [
          {"virus", "viruses"}
        ],
        singular: [
          {"thieves", "thief"}
        ],
        uncountable: [
          "drops-inflector"
        ]
    end

    test "respects customized plural configuration" do
      assert Test.Inflector.pluralize("virus") == "viruses"
    end

    test "respects customized singular configuration" do
      assert Test.Inflector.singularize("thieves") == "thief"
    end

    test "respects customized uncountable configuration" do
      assert Test.Inflector.pluralize("drops-inflector") == "drops-inflector"
      assert Test.Inflector.singularize("drops-inflector") == "drops-inflector"
      assert Test.Inflector.uncountable?("drops-inflector") == true
    end

    test "falls back to default rules for non-customized words" do
      assert Test.Inflector.pluralize("book") == "books"
      assert Test.Inflector.singularize("books") == "book"
      assert Test.Inflector.uncountable?("book") == false
    end

    test "all functions are available" do
      # Test that all functions are properly delegated
      assert Test.Inflector.camelize_lower("data_mapper") == "dataMapper"
      assert Test.Inflector.camelize_upper("data_mapper") == "DataMapper"
      assert Test.Inflector.camelize("data_mapper") == "DataMapper"
      assert Test.Inflector.constantize("String") == String
      assert Test.Inflector.classify("books") == "Book"
      assert Test.Inflector.dasherize("drops_inflector") == "drops-inflector"
      assert Test.Inflector.demodulize("Drops::Inflector") == "Inflector"
      assert Test.Inflector.humanize("drops_inflector") == "Drops inflector"
      assert Test.Inflector.foreign_key("Message") == "message_id"
      assert Test.Inflector.ordinalize(1) == "1st"
      assert Test.Inflector.tableize("Book") == "books"
      assert Test.Inflector.underscore("DataMapper") == "data_mapper"
    end
  end

  describe "multiple custom inflectors" do
    defmodule CustomInflector1 do
      use Drops.Inflector,
        plural: [
          {"person", "people"}
        ]
    end

    defmodule CustomInflector2 do
      use Drops.Inflector,
        plural: [
          {"person", "persons"}
        ]
    end

    test "different inflectors can have different rules" do
      assert CustomInflector1.pluralize("person") == "people"
      assert CustomInflector2.pluralize("person") == "persons"
    end
  end

  describe "empty configuration" do
    defmodule EmptyInflector do
      use Drops.Inflector
    end

    test "works with no custom configuration" do
      assert EmptyInflector.pluralize("book") == "books"
      assert EmptyInflector.singularize("books") == "book"
      assert EmptyInflector.uncountable?("money") == true
    end
  end

  describe "complex configuration" do
    defmodule ComplexInflector do
      use Drops.Inflector,
        plural: [
          {"octopus", "octopi"},
          {"virus", "viruses"}
        ],
        singular: [
          {"octopi", "octopus"},
          {"viruses", "virus"}
        ],
        uncountable: [
          "equipment",
          "software"
        ]
    end

    test "handles multiple rules of each type" do
      assert ComplexInflector.pluralize("octopus") == "octopi"
      assert ComplexInflector.pluralize("virus") == "viruses"
      assert ComplexInflector.singularize("octopi") == "octopus"
      assert ComplexInflector.singularize("viruses") == "virus"
      assert ComplexInflector.uncountable?("equipment") == true
      assert ComplexInflector.uncountable?("software") == true
    end

    test "custom rules take precedence over defaults" do
      # Default would be "octopuses", but we override to "octopi"
      assert ComplexInflector.pluralize("octopus") == "octopi"
    end
  end
end
