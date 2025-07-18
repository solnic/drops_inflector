# Elixir Drops 💦

## Inflector

[![CI](https://github.com/solnic/drops/actions/workflows/ci.yml/badge.svg)](https://github.com/solnic/drops_inflector/actions/workflows/ci.yml) [![Hex pm](https://img.shields.io/hexpm/v/drops_inflector.svg?style=flat)](https://hex.pm/packages/drops_inflector) [![hex.pm downloads](https://img.shields.io/hexpm/dt/drops_inflector.svg?style=flat)](https://hex.pm/packages/drops_inflector)


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
    ],
    acronyms: [
      "API",
      "XML",
      "HTML"
    ]
end

# Use your custom inflector
MyInflector.pluralize("virus")     # => "viruses"
MyInflector.singularize("thieves") # => "thief"
MyInflector.uncountable?("equipment") # => true

# Acronyms are properly handled in camelization
MyInflector.camelize("api_access")     # => "APIAccess"
MyInflector.camelize_lower("xml_data") # => "xmlData"

# All other functions work the same way
MyInflector.camelize("data_mapper")    # => "DataMapper"
MyInflector.tableize("User")           # => "users"
```

### Acronym Support

Drops.Inflector includes built-in support for common acronyms like API, JSON, HTTP, etc. You can also define custom acronyms that will be properly handled during camelization:

```elixir
defmodule APIInflector do
  use Drops.Inflector,
    acronyms: ["API", "XML", "HTML", "CSS"]
end

APIInflector.camelize("api_access")        # => "APIAccess"
APIInflector.camelize("xml_http_request")  # => "XMLHTTPRequest"
APIInflector.camelize_lower("html_css")    # => "htmlCSS"
```

The default inflector already includes these acronyms: API, CSRF, CSV, DB, HMAC, HTTP, JSON, OpenSSL.

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

