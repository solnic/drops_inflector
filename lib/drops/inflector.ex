defmodule Drops.Inflector do
  @moduledoc """
  String inflection library for Elixir.

  This module provides functions for transforming strings in various ways,
  including pluralization, singularization, camelization, and more.

  Based on the dry-inflector Ruby library.

  ## Configuration

  You can create custom inflector modules with specific configuration using the `__using__` macro:

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
            "drops-inflector",
            "equipment"
          ],
          acronyms: [
            "API",
            "XML",
            "HTML"
          ]
      end

      MyInflector.pluralize("virus")     # => "viruses"
      MyInflector.singularize("thieves") # => "thief"
      MyInflector.uncountable?("equipment") # => true
      MyInflector.camelize("api_access")  # => "APIAccess"

  Custom inflectors have all the same functions as the main `Drops.Inflector` module,
  but use your custom rules in addition to the default rules. Custom rules take
  precedence over default rules.

  ## Available Functions

  All inflector modules (both the main module and custom ones) provide these functions:

  - `camelize_lower/1` - Lower camelCase
  - `camelize_upper/1` - Upper CamelCase
  - `camelize/1` - Alias for `camelize_upper/1`
  - `modulize/1` - Convert string to module constant
  - `classify/1` - Convert to class name
  - `dasherize/1` - Convert underscores to dashes
  - `demodulize/1` - Extract last part of module name
  - `humanize/1` - Convert to human-readable form
  - `foreign_key/1` - Create foreign key name
  - `ordinalize/1` - Convert number to ordinal
  - `pluralize/1` - Convert to plural form
  - `singularize/1` - Convert to singular form
  - `tableize/1` - Convert to table name
  - `underscore/1` - Convert to snake_case
  - `uncountable?/1` - Check if word is uncountable
  """

  alias Drops.Inflector.Inflections

  # Constants for ordinalization
  @ordinalize_th %{11 => true, 12 => true, 13 => true}
  @default_separator " "

  @on_load :setup_inflections

  @doc false
  def get_inflections(module \\ __MODULE__) do
    :persistent_term.get({module, :inflections})
  end

  @doc false
  def put_inflections(module, inflections) do
    :persistent_term.put({module, :inflections}, inflections)
  end

  @doc false
  def setup_inflections do
    put_inflections(__MODULE__, Inflections.new())
  end

  @doc """
  Macro for creating custom inflector modules with specific configuration.

  ## Examples

      defmodule MyInflector do
        use Drops.Inflector,
          plural: [
            {"virus", "viruses"}
          ],
          singular: [
            {"thieves", "thief"}
          ],
          uncountable: [
            "drops-inflector"
          ],
          acronyms: [
            "API"
          ]
      end

      MyInflector.pluralize("virus") # => "viruses"
      MyInflector.camelize("api_access") # => "APIAccess"
  """
  defmacro __using__(opts) do
    quote do
      import Drops.Inflector, only: [put_inflections: 2, get_inflections: 1]

      @on_load :setup_inflections

      def setup_inflections do
        put_inflections(__MODULE__, Inflections.new(unquote(opts)))
      end

      def camelize_lower(input) do
        Drops.Inflector.camelize_lower(input, inflections: get_inflections(__MODULE__))
      end

      def camelize_upper(input) do
        Drops.Inflector.camelize_upper(input, inflections: get_inflections(__MODULE__))
      end

      def camelize(input) do
        Drops.Inflector.camelize(input, inflections: get_inflections(__MODULE__))
      end

      def modulize(input) do
        Drops.Inflector.modulize(input, inflections: get_inflections(__MODULE__))
      end

      def classify(input) do
        Drops.Inflector.classify(input, inflections: get_inflections(__MODULE__))
      end

      def dasherize(input) do
        Drops.Inflector.dasherize(input, inflections: get_inflections(__MODULE__))
      end

      def demodulize(input) do
        Drops.Inflector.demodulize(input, inflections: get_inflections(__MODULE__))
      end

      def humanize(input) do
        Drops.Inflector.humanize(input, inflections: get_inflections(__MODULE__))
      end

      def foreign_key(input) do
        Drops.Inflector.foreign_key(input, inflections: get_inflections(__MODULE__))
      end

      def ordinalize(number) do
        Drops.Inflector.ordinalize(number, inflections: get_inflections(__MODULE__))
      end

      def pluralize(input) do
        Drops.Inflector.pluralize(input, inflections: get_inflections(__MODULE__))
      end

      def singularize(input) do
        Drops.Inflector.singularize(input, inflections: get_inflections(__MODULE__))
      end

      def tableize(input) do
        Drops.Inflector.tableize(input, inflections: get_inflections(__MODULE__))
      end

      def underscore(input) do
        Drops.Inflector.underscore(input, inflections: get_inflections(__MODULE__))
      end

      def uncountable?(input) do
        Drops.Inflector.uncountable?(input, inflections: get_inflections(__MODULE__))
      end
    end
  end

  @doc """
  Lower camelize a string.

  ## Examples

      iex> Drops.Inflector.camelize_lower("data_mapper")
      "dataMapper"

      iex> Drops.Inflector.camelize_lower("drops/inflector")
      "drops.Inflector"
  """
  @spec camelize_lower(String.t() | atom(), keyword()) :: String.t()
  def camelize_lower(input, opts \\ []) do
    inflections = Keyword.get(opts, :inflections, get_inflections())
    internal_camelize(to_string(input), false, inflections)
  end

  @doc """
  Upper camelize a string.

  ## Examples

      iex> Drops.Inflector.camelize_upper("data_mapper")
      "DataMapper"

      iex> Drops.Inflector.camelize_upper("drops/inflector")
      "Drops.Inflector"
  """
  @spec camelize_upper(String.t() | atom(), keyword()) :: String.t()
  def camelize_upper(input, opts \\ []) do
    inflections = Keyword.get(opts, :inflections, get_inflections())
    internal_camelize(to_string(input), true, inflections)
  end

  @doc """
  Alias for camelize_upper/1.
  """
  @spec camelize(String.t() | atom(), keyword()) :: String.t()
  def camelize(input, opts \\ []), do: camelize_upper(input, opts)

  @doc """
  Find a constant with the name specified in the argument string.

  ## Examples

      iex> Drops.Inflector.modulize("String")
      String

      iex> Drops.Inflector.modulize("Enum")
      Enum
  """
  @spec modulize(String.t() | atom(), keyword()) :: module()
  def modulize(input, _opts \\ []) do
    # modulize doesn't use inflections, but we keep the interface consistent
    input
    |> to_string()
    |> String.split(".")
    |> Enum.map(&String.to_existing_atom/1)
    |> Module.concat()
  end

  @doc """
  Classify a string.

  ## Examples

      iex> Drops.Inflector.classify("books")
      "Book"

      iex> Drops.Inflector.classify("admin.users")
      "User"
  """
  @spec classify(String.t() | atom(), keyword()) :: String.t()
  def classify(input, opts \\ []) do
    input
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> singularize(opts)
    |> camelize(opts)
  end

  @doc """
  Dasherize a string.

  ## Examples

      iex> Drops.Inflector.dasherize("drops_inflector")
      "drops-inflector"
  """
  @spec dasherize(String.t() | atom(), keyword()) :: String.t()
  def dasherize(input, _opts \\ []) do
    input
    |> to_string()
    |> String.replace("_", "-")
  end

  @doc """
  Demodulize a string.

  ## Examples

      iex> Drops.Inflector.demodulize("Drops.Inflector")
      "Inflector"

      iex> Drops.Inflector.demodulize("String")
      "String"
  """
  @spec demodulize(String.t() | atom(), keyword()) :: String.t()
  def demodulize(input, _opts \\ []) do
    input
    |> to_string()
    |> String.split(".")
    |> List.last()
  end

  @doc """
  Humanize a string.

  ## Examples

      iex> Drops.Inflector.humanize("drops_inflector")
      "Drops inflector"

      iex> Drops.Inflector.humanize("author_id")
      "Author"
  """
  @spec humanize(String.t() | atom(), keyword()) :: String.t()
  def humanize(input, _opts \\ []) do
    input = to_string(input)

    # Apply human rules first (when we have them)
    result = input

    # Remove _id suffix
    result = String.replace_suffix(result, "_id", "")

    # Replace underscores with spaces
    result = String.replace(result, "_", " ")

    # Find separator (first non-word character or default to space)
    separator =
      case Regex.run(~r/(\W)/, result) do
        [_, sep] -> sep
        nil -> @default_separator
      end

    # Split by separator and capitalize appropriately
    result
    |> String.split(separator)
    |> Enum.with_index()
    |> Enum.map(fn {word, index} ->
      # Apply acronym rules (when we have them) and capitalize first word
      if index == 0, do: String.capitalize(word), else: word
    end)
    |> Enum.join(separator)
  end

  @doc """
  Creates a foreign key name.

  ## Examples

      iex> Drops.Inflector.foreign_key("Message")
      "message_id"

      iex> Drops.Inflector.foreign_key("Admin.User")
      "user_id"
  """
  @spec foreign_key(String.t() | atom(), keyword()) :: String.t()
  def foreign_key(input, opts \\ []) do
    input
    |> demodulize(opts)
    |> singularize(opts)
    |> underscore(opts)
    |> Kernel.<>("_id")
  end

  @doc """
  Ordinalize a number.

  ## Examples

      iex> Drops.Inflector.ordinalize(1)
      "1st"

      iex> Drops.Inflector.ordinalize(2)
      "2nd"

      iex> Drops.Inflector.ordinalize(3)
      "3rd"

      iex> Drops.Inflector.ordinalize(10)
      "10th"

      iex> Drops.Inflector.ordinalize(23)
      "23rd"
  """
  @spec ordinalize(integer(), keyword()) :: String.t()
  def ordinalize(number, _opts \\ []) when is_integer(number) do
    abs_value = abs(number)

    cond do
      Map.has_key?(@ordinalize_th, rem(abs_value, 100)) ->
        "#{number}th"

      rem(abs_value, 10) == 1 ->
        "#{number}st"

      rem(abs_value, 10) == 2 ->
        "#{number}nd"

      rem(abs_value, 10) == 3 ->
        "#{number}rd"

      true ->
        "#{number}th"
    end
  end

  @doc """
  Pluralize a string.

  ## Examples

      iex> Drops.Inflector.pluralize("book")
      "books"

      iex> Drops.Inflector.pluralize("money")
      "money"
  """
  @spec pluralize(String.t() | atom(), keyword()) :: String.t()
  def pluralize(input, opts \\ []) do
    input = to_string(input)
    inflections = Keyword.get(opts, :inflections, get_inflections())

    if uncountable?(input, opts) do
      input
    else
      inflections.plurals
      |> Drops.Inflector.Rules.apply_to(input)
    end
  end

  @doc """
  Singularize a string.

  ## Examples

      iex> Drops.Inflector.singularize("books")
      "book"

      iex> Drops.Inflector.singularize("money")
      "money"
  """
  @spec singularize(String.t() | atom(), keyword()) :: String.t()
  def singularize(input, opts \\ []) do
    input = to_string(input)
    inflections = Keyword.get(opts, :inflections, get_inflections())

    if uncountable?(input, opts) do
      input
    else
      inflections.singulars
      |> Drops.Inflector.Rules.apply_to(input)
    end
  end

  @doc """
  Tableize a string.

  ## Examples

      iex> Drops.Inflector.tableize("Book")
      "books"

      iex> Drops.Inflector.tableize("Admin.User")
      "admin_users"
  """
  @spec tableize(String.t() | atom(), keyword()) :: String.t()
  def tableize(input, opts \\ []) do
    input
    |> to_string()
    |> String.replace(".", "_")
    |> underscore(opts)
    |> pluralize(opts)
  end

  @doc """
  Underscore a string.

  ## Examples

      iex> Drops.Inflector.underscore("drops-inflector")
      "drops_inflector"

      iex> Drops.Inflector.underscore("DataMapper")
      "data_mapper"
  """
  @spec underscore(String.t() | atom(), keyword()) :: String.t()
  def underscore(input, _opts \\ []) do
    input = to_string(input)

    # Replace :: with /
    input = String.replace(input, ".", "/")

    # Apply acronym transformations (when we have them)
    # For now, just do basic underscore transformation

    # Handle sequences of capitals followed by lowercase
    input = Regex.replace(~r/([A-Z\d]+)([A-Z][a-z])/, input, "\\1_\\2")

    # Handle lowercase/digit followed by uppercase
    input = Regex.replace(~r/([a-z\d])([A-Z])/, input, "\\1_\\2")

    # Replace dashes with underscores
    input = String.replace(input, "-", "_")

    # Convert to lowercase
    String.downcase(input)
  end

  @doc """
  Check if the input is an uncountable word.

  ## Examples

      iex> Drops.Inflector.uncountable?("money")
      true

      iex> Drops.Inflector.uncountable?("book")
      false
  """
  @spec uncountable?(String.t(), keyword()) :: boolean()
  def uncountable?(input, opts \\ []) when is_binary(input) do
    inflections = Keyword.get(opts, :inflections, get_inflections())

    # Check if input is only whitespace
    # Check if it's in the uncountables set
    # Check if the last word (after underscore or word boundary) is uncountable
    String.match?(input, ~r/\A[[:space:]]*\z/) ||
      MapSet.member?(inflections.uncountables, String.downcase(input)) ||
      input
      |> String.split(~r/_|\b/)
      |> List.last()
      |> String.downcase()
      |> then(&MapSet.member?(inflections.uncountables, &1))
  end

  # Private helper functions

  defp internal_camelize(input, upper, inflections) do
    # First handle path separators
    input = String.replace(input, "/", ".")

    # Split by "." to handle each module part separately
    parts = String.split(input, ".")

    camelized_parts =
      Enum.with_index(parts, fn part, index ->
        # Split each part on underscores and dashes
        word_parts = Regex.split(~r/[_-]/, part)

        case word_parts do
          [first | rest] ->
            # For the first module part, respect the upper flag
            # For subsequent module parts, always capitalize
            should_capitalize_first = upper || index > 0

            # Apply acronym rules to the first part
            first_part =
              if should_capitalize_first do
                Drops.Inflector.Acronyms.apply_to(inflections.acronyms, first, capitalize: true)
              else
                # For lower camelCase, check if it's an acronym but keep it lowercase if it's the first word
                case Map.get(inflections.acronyms.rules, String.downcase(first)) do
                  nil -> String.downcase(first)
                  # Keep first word lowercase in camelCase
                  _acronym -> String.downcase(first)
                end
              end

            # Apply acronym rules to the rest of the parts
            rest_parts =
              Enum.map(rest, fn word ->
                Drops.Inflector.Acronyms.apply_to(inflections.acronyms, word, capitalize: true)
              end)

            Enum.join([first_part | rest_parts])
        end
      end)

    Enum.join(camelized_parts, ".")
  end
end
