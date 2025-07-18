defmodule Drops.InflectorTest do
  use ExUnit.Case
  doctest Drops.Inflector

  alias Drops.Inflector

  describe "camelize_lower/1" do
    test "converts snake_case to camelCase" do
      assert Inflector.camelize_lower("data_mapper") == "dataMapper"
      assert Inflector.camelize_lower("drops_inflector") == "dropsInflector"
      assert Inflector.camelize_lower("user_name") == "userName"
    end

    test "handles dashes" do
      assert Inflector.camelize_lower("drops-inflector") == "dropsInflector"
    end

    test "handles paths" do
      assert Inflector.camelize_lower("drops/inflector") == "drops.Inflector"
    end

    test "accepts atoms" do
      assert Inflector.camelize_lower(:data_mapper) == "dataMapper"
    end
  end

  describe "camelize_upper/1" do
    test "converts snake_case to PascalCase" do
      assert Inflector.camelize_upper("data_mapper") == "DataMapper"
      assert Inflector.camelize_upper("drops_inflector") == "DropsInflector"
      assert Inflector.camelize_upper("user_name") == "UserName"
    end

    test "handles dashes" do
      assert Inflector.camelize_upper("drops-inflector") == "DropsInflector"
    end

    test "handles paths" do
      assert Inflector.camelize_upper("drops/inflector") == "Drops.Inflector"
    end

    test "accepts atoms" do
      assert Inflector.camelize_upper(:data_mapper) == "DataMapper"
    end
  end

  describe "camelize/1" do
    test "is an alias for camelize_upper/1" do
      assert Inflector.camelize("data_mapper") == Inflector.camelize_upper("data_mapper")
    end
  end

  describe "modulize/1" do
    test "converts string to module" do
      assert Inflector.modulize("String") == String
      assert Inflector.modulize("Enum") == Enum
    end

    test "handles nested modules" do
      assert Inflector.modulize("Drops.Inflector") == Drops.Inflector
    end

    test "accepts atoms" do
      assert Inflector.modulize(:String) == String
    end
  end

  describe "classify/1" do
    test "converts plural table names to singular class names" do
      assert Inflector.classify("books") == "Book"
      assert Inflector.classify("users") == "User"
      assert Inflector.classify("admin_users") == "AdminUser"
    end

    test "handles dotted names" do
      assert Inflector.classify("admin.users") == "User"
    end

    test "accepts atoms" do
      assert Inflector.classify(:books) == "Book"
    end
  end

  describe "dasherize/1" do
    test "converts underscores to dashes" do
      assert Inflector.dasherize("drops_inflector") == "drops-inflector"
      assert Inflector.dasherize("user_name") == "user-name"
    end

    test "accepts atoms" do
      assert Inflector.dasherize(:drops_inflector) == "drops-inflector"
    end
  end

  describe "demodulize/1" do
    test "extracts the last part of a module name" do
      assert Inflector.demodulize("Drops.Inflector") == "Inflector"
      assert Inflector.demodulize("String") == "String"
      assert Inflector.demodulize("Admin.User") == "User"
    end

    test "accepts atoms" do
      assert Inflector.demodulize(:"Drops.Inflector") == "Inflector"
    end
  end

  describe "humanize/1" do
    test "converts snake_case to human readable" do
      assert Inflector.humanize("drops_inflector") == "Drops inflector"
      assert Inflector.humanize("user_name") == "User name"
    end

    test "removes _id suffix" do
      assert Inflector.humanize("author_id") == "Author"
      assert Inflector.humanize("user_id") == "User"
    end

    test "accepts atoms" do
      assert Inflector.humanize(:drops_inflector) == "Drops inflector"
    end
  end

  describe "foreign_key/1" do
    test "creates foreign key names" do
      assert Inflector.foreign_key("Message") == "message_id"
      assert Inflector.foreign_key("User") == "user_id"
    end

    test "handles nested modules" do
      assert Inflector.foreign_key("Admin.User") == "user_id"
    end

    test "accepts atoms" do
      assert Inflector.foreign_key(:Message) == "message_id"
    end
  end

  describe "ordinalize/1" do
    test "converts numbers to ordinals" do
      assert Inflector.ordinalize(1) == "1st"
      assert Inflector.ordinalize(2) == "2nd"
      assert Inflector.ordinalize(3) == "3rd"
      assert Inflector.ordinalize(4) == "4th"
      assert Inflector.ordinalize(10) == "10th"
      assert Inflector.ordinalize(11) == "11th"
      assert Inflector.ordinalize(12) == "12th"
      assert Inflector.ordinalize(13) == "13th"
      assert Inflector.ordinalize(21) == "21st"
      assert Inflector.ordinalize(22) == "22nd"
      assert Inflector.ordinalize(23) == "23rd"
      assert Inflector.ordinalize(101) == "101st"
      assert Inflector.ordinalize(111) == "111th"
    end

    test "handles negative numbers" do
      assert Inflector.ordinalize(-1) == "-1st"
      assert Inflector.ordinalize(-11) == "-11th"
    end
  end

  describe "pluralize/1" do
    test "pluralizes regular words" do
      assert Inflector.pluralize("book") == "books"
      assert Inflector.pluralize("user") == "users"
      assert Inflector.pluralize("cat") == "cats"
    end

    test "handles words ending in s" do
      assert Inflector.pluralize("class") == "classes"
      assert Inflector.pluralize("glass") == "glasses"
    end

    test "handles words ending in y" do
      assert Inflector.pluralize("city") == "cities"
      assert Inflector.pluralize("party") == "parties"
    end

    test "handles irregular plurals" do
      assert Inflector.pluralize("person") == "people"
      assert Inflector.pluralize("child") == "children"
      assert Inflector.pluralize("foot") == "feet"
    end

    test "handles uncountable words" do
      assert Inflector.pluralize("money") == "money"
      assert Inflector.pluralize("information") == "information"
      assert Inflector.pluralize("sheep") == "sheep"
    end

    test "accepts atoms" do
      assert Inflector.pluralize(:book) == "books"
    end
  end

  describe "singularize/1" do
    test "singularizes regular words" do
      assert Inflector.singularize("books") == "book"
      assert Inflector.singularize("users") == "user"
      assert Inflector.singularize("cats") == "cat"
    end

    test "handles words ending in ies" do
      assert Inflector.singularize("cities") == "city"
      assert Inflector.singularize("parties") == "party"
    end

    test "handles irregular singulars" do
      assert Inflector.singularize("people") == "person"
      assert Inflector.singularize("children") == "child"
      assert Inflector.singularize("feet") == "foot"
    end

    test "handles uncountable words" do
      assert Inflector.singularize("money") == "money"
      assert Inflector.singularize("information") == "information"
      assert Inflector.singularize("sheep") == "sheep"
    end

    test "accepts atoms" do
      assert Inflector.singularize(:books) == "book"
    end
  end

  describe "tableize/1" do
    test "converts class names to table names" do
      assert Inflector.tableize("Book") == "books"
      assert Inflector.tableize("User") == "users"
      assert Inflector.tableize("AdminUser") == "admin_users"
    end

    test "handles nested modules" do
      assert Inflector.tableize("Admin.User") == "admin_users"
    end

    test "accepts atoms" do
      assert Inflector.tableize(:Book) == "books"
    end
  end

  describe "underscore/1" do
    test "converts CamelCase to snake_case" do
      assert Inflector.underscore("DataMapper") == "data_mapper"
      assert Inflector.underscore("DropsInflector") == "drops_inflector"
      assert Inflector.underscore("UserName") == "user_name"
    end

    test "handles dashes" do
      assert Inflector.underscore("drops-inflector") == "drops_inflector"
    end

    test "handles paths" do
      assert Inflector.underscore("Drops.Inflector") == "drops/inflector"
    end

    test "accepts atoms" do
      assert Inflector.underscore(:DataMapper) == "data_mapper"
    end
  end

  describe "uncountable?/1" do
    test "returns true for uncountable words" do
      assert Inflector.uncountable?("money") == true
      assert Inflector.uncountable?("information") == true
      assert Inflector.uncountable?("sheep") == true
      assert Inflector.uncountable?("fish") == true
    end

    test "returns false for countable words" do
      assert Inflector.uncountable?("book") == false
      assert Inflector.uncountable?("user") == false
      assert Inflector.uncountable?("cat") == false
    end

    test "returns true for whitespace-only strings" do
      assert Inflector.uncountable?("   ") == true
      assert Inflector.uncountable?("\t\n") == true
    end
  end
end
