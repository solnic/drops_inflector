defmodule Drops.Inflector.ConfigTest do
  use ExUnit.Case
  doctest Drops.Inflector

  alias Drops.Inflector.{Acronyms, Inflections, Rules}

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
      assert Test.Inflector.camelize_lower("data_mapper") == "dataMapper"
      assert Test.Inflector.camelize_upper("data_mapper") == "DataMapper"
      assert Test.Inflector.camelize("data_mapper") == "DataMapper"
      assert Test.Inflector.constantize("String") == String
      assert Test.Inflector.classify("books") == "Book"
      assert Test.Inflector.dasherize("drops_inflector") == "drops-inflector"
      assert Test.Inflector.demodulize("Drops.Inflector") == "Inflector"
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
      assert ComplexInflector.pluralize("octopus") == "octopi"
    end
  end

  describe "edge cases and internal functions" do
    test "camelization handles empty parts" do
      assert Drops.Inflector.camelize_lower("") == ""
      assert Drops.Inflector.camelize_upper("") == ""
    end

    test "Rules.each function" do
      rules =
        Rules.new()
        |> Rules.insert(0, {"test", "tests"})
        |> Rules.insert(0, {"book", "books"})

      Rules.each(rules, fn rule ->
        send(self(), {:rule, rule})
      end)

      assert_receive {:rule, {"book", "books"}}
      assert_receive {:rule, {"test", "tests"}}
    end

    test "Acronyms.apply_to with different options" do
      acronyms =
        Acronyms.new()
        |> Acronyms.add("api", "API")
        |> Acronyms.add("xml", "XML")

      assert Acronyms.apply_to(acronyms, "api") == "API"
      assert Acronyms.apply_to(acronyms, "unknown") == "Unknown"

      assert Acronyms.apply_to(acronyms, "api", capitalize: false) == "API"
      assert Acronyms.apply_to(acronyms, "unknown", capitalize: false) == "unknown"
    end

    test "Acronyms.regex function" do
      acronyms =
        Acronyms.new()
        |> Acronyms.add("api", "API")
        |> Acronyms.add("xml", "XML")

      regex = Acronyms.regex(acronyms)
      assert is_struct(regex, Regex)
    end

    test "Inflections.uncountable with single word" do
      inflections =
        Inflections.new()
        |> Inflections.uncountable("data")

      assert Drops.Inflector.uncountable?("data", inflections: inflections) == true
    end

    test "Inflections.acronym with single word" do
      inflections =
        Inflections.new()
        |> Inflections.acronym("api")

      assert is_struct(inflections, Inflections)
    end

    test "Inflections.human function" do
      inflections =
        Inflections.new()
        |> Inflections.human("employee_salary", "Employee Salary")

      assert is_struct(inflections, Inflections)
    end

    test "Rules.apply_to with empty rules" do
      alias Drops.Inflector.Rules

      empty_rules = Rules.new()
      result = Rules.apply_to(empty_rules, "test")
      assert result == "test"
    end

    test "cached inflections in custom inflector" do
      defmodule CachedInflector do
        use Drops.Inflector,
          plural: [
            {"test", "tests"}
          ]
      end

      result1 = CachedInflector.pluralize("test")
      assert result1 == "tests"

      result2 = CachedInflector.pluralize("test")
      assert result2 == "tests"
    end

    test "regex rule that doesn't match" do
      inflections =
        Inflections.new()
        |> Inflections.plural(~r/xyz$/, "xyzs")

      result = Drops.Inflector.pluralize("book", inflections: inflections)
      assert result == "books"
    end

    test "uncountable with whitespace-only string" do
      assert Drops.Inflector.uncountable?("   ") == true
      assert Drops.Inflector.uncountable?("\t\n") == true
      assert Drops.Inflector.uncountable?("") == true
    end

    test "Acronyms with empty rules" do
      empty_acronyms = Acronyms.new()
      regex = Acronyms.regex(empty_acronyms)

      assert is_struct(regex, Regex)
      refute Regex.match?(regex, "test")
      refute Regex.match?(regex, "API")
    end

    test "humanize with non-word separator" do
      result = Drops.Inflector.humanize("user-name")
      assert result == "User-name"

      result2 = Drops.Inflector.humanize("user.name")
      assert result2 == "User.name"
    end
  end
end
