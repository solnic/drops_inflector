# Drops.Inflector

Inflection utils for Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `drops_inflector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:drops_inflector, "~> 0.1.0"}
  ]
end
```

## Basic Usage

The `Drops.Inflector` module provides a comprehensive set of string inflection functions:

```elixir
# Pluralization and singularization
Drops.Inflector.pluralize("book")        # => "books"
Drops.Inflector.pluralize("person")      # => "people"
Drops.Inflector.singularize("books")     # => "book"
Drops.Inflector.singularize("children")  # => "child"

# Case transformations
Drops.Inflector.camelize("data_mapper")        # => "DataMapper"
Drops.Inflector.camelize_lower("data_mapper")  # => "dataMapper"
Drops.Inflector.underscore("DataMapper")       # => "data_mapper"
Drops.Inflector.dasherize("drops_inflector")   # => "drops-inflector"

# Human-friendly transformations
Drops.Inflector.humanize("drops_inflector")  # => "Drops inflector"
Drops.Inflector.humanize("author_id")        # => "Author"

# Database and class name transformations
Drops.Inflector.tableize("User")           # => "users"
Drops.Inflector.classify("admin_users")    # => "AdminUser"
Drops.Inflector.foreign_key("Message")     # => "message_id"

# Module operations
Drops.Inflector.demodulize("Drops.Inflector")  # => "Inflector"
Drops.Inflector.modulize("String")             # => String

# Number ordinalization
Drops.Inflector.ordinalize(1)   # => "1st"
Drops.Inflector.ordinalize(22)  # => "22nd"
Drops.Inflector.ordinalize(103) # => "103rd"

# Check if a word is uncountable
Drops.Inflector.uncountable?("money")       # => true
Drops.Inflector.uncountable?("information") # => true
Drops.Inflector.uncountable?("book")        # => false
```

## Custom Inflectors

You can create custom inflector modules with specific rules using the `__using__` macro. Custom rules take precedence over default rules:

```elixir
defmodule MyInflector do
  use Drops.Inflector,
    plural: [
      {"virus", "viruses"},
      {"octopus", "octopi"}
    ],
    singular: [
      {"thieves", "thief"},
      {"octopi", "octopus"}
    ],
    uncountable: [
      "equipment",
      "software"
    ]
end

# Use your custom inflector
MyInflector.pluralize("virus")     # => "viruses"
MyInflector.singularize("thieves") # => "thief"
MyInflector.uncountable?("equipment") # => true

# All other functions work the same way
MyInflector.camelize("data_mapper")    # => "DataMapper"
MyInflector.tableize("User")           # => "users"
```

### Multiple Custom Inflectors

You can create multiple inflectors with different rules:

```elixir
defmodule MedicalInflector do
  use Drops.Inflector,
    plural: [
      {"virus", "viruses"},
      {"bacterium", "bacteria"}
    ]
end

defmodule TechInflector do
  use Drops.Inflector,
    plural: [
      {"server", "servers"},
      {"database", "databases"}
    ],
    uncountable: [
      "software",
      "hardware"
    ]
end

MedicalInflector.pluralize("virus")    # => "viruses"
TechInflector.pluralize("server")      # => "servers"
TechInflector.uncountable?("software") # => true
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/drops_inflector>.

