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

  # Get default inflections instance
  defp inflections do
    Inflections.new()
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
      @inflections_config unquote(opts)

      # Build custom inflections at runtime with caching
      defp custom_inflections do
        case Process.get({__MODULE__, :custom_inflections}) do
          nil ->
            inflections = Drops.Inflector.build_custom_inflections(@inflections_config)
            Process.put({__MODULE__, :custom_inflections}, inflections)
            inflections

          cached_inflections ->
            cached_inflections
        end
      end

      # Define all public functions that delegate to Drops.Inflector with custom inflections
      def camelize_lower(input) do
        Drops.Inflector.camelize_lower(input, inflections: custom_inflections())
      end

      def camelize_upper(input) do
        Drops.Inflector.camelize_upper(input, inflections: custom_inflections())
      end

      def camelize(input) do
        Drops.Inflector.camelize(input, inflections: custom_inflections())
      end

      def modulize(input) do
        Drops.Inflector.modulize(input, inflections: custom_inflections())
      end

      def classify(input) do
        Drops.Inflector.classify(input, inflections: custom_inflections())
      end

      def dasherize(input) do
        Drops.Inflector.dasherize(input, inflections: custom_inflections())
      end

      def demodulize(input) do
        Drops.Inflector.demodulize(input, inflections: custom_inflections())
      end

      def humanize(input) do
        Drops.Inflector.humanize(input, inflections: custom_inflections())
      end

      def foreign_key(input) do
        Drops.Inflector.foreign_key(input, inflections: custom_inflections())
      end

      def ordinalize(number) do
        Drops.Inflector.ordinalize(number, inflections: custom_inflections())
      end

      def pluralize(input) do
        Drops.Inflector.pluralize(input, inflections: custom_inflections())
      end

      def singularize(input) do
        Drops.Inflector.singularize(input, inflections: custom_inflections())
      end

      def tableize(input) do
        Drops.Inflector.tableize(input, inflections: custom_inflections())
      end

      def underscore(input) do
        Drops.Inflector.underscore(input, inflections: custom_inflections())
      end

      def uncountable?(input) do
        Drops.Inflector.uncountable?(input, inflections: custom_inflections())
      end
    end
  end

  @doc """
  Builds custom inflections from configuration options.
  """
  def build_custom_inflections(opts) do
    inflections = Inflections.new()

    inflections
    |> apply_custom_plurals(Keyword.get(opts, :plural, []))
    |> apply_custom_singulars(Keyword.get(opts, :singular, []))
    |> apply_custom_uncountables(Keyword.get(opts, :uncountable, []))
    |> apply_custom_acronyms(Keyword.get(opts, :acronyms, []))
  end

  defp apply_custom_plurals(inflections, plurals) do
    Enum.reduce(plurals, inflections, fn {singular, plural}, acc ->
      Inflections.plural(acc, singular, plural)
    end)
  end

  defp apply_custom_singulars(inflections, singulars) do
    Enum.reduce(singulars, inflections, fn {plural, singular}, acc ->
      Inflections.singular(acc, plural, singular)
    end)
  end

  defp apply_custom_uncountables(inflections, uncountables) do
    Inflections.uncountable(inflections, uncountables)
  end

  defp apply_custom_acronyms(inflections, acronyms) do
    Inflections.acronym(inflections, acronyms)
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
    inflections = Keyword.get(opts, :inflections, inflections())
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
    inflections = Keyword.get(opts, :inflections, inflections())
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
    inflections = Keyword.get(opts, :inflections, inflections())

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
    inflections = Keyword.get(opts, :inflections, inflections())

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
    inflections = Keyword.get(opts, :inflections, inflections())

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

defmodule Drops.Inflector.Rules do
  @moduledoc """
  A set of inflection rules that can be applied to words.

  This module manages a list of rules (patterns and replacements) that are
  applied in order until one matches and transforms the input word.
  """

  defstruct rules: []

  @type rule :: {Regex.t() | String.t(), String.t()}
  @type t :: %__MODULE__{rules: [rule()]}

  @doc """
  Creates a new empty Rules struct.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Applies the rules to a word, returning the transformed word.

  Rules are applied in order until one matches and transforms the word.
  If no rules match, the original word is returned.
  """
  @spec apply_to(t(), String.t()) :: String.t()
  def apply_to(%__MODULE__{rules: rules}, word) do
    apply_rules(rules, word)
  end

  @doc """
  Inserts a rule at the specified index.
  """
  @spec insert(t(), non_neg_integer(), rule()) :: t()
  def insert(%__MODULE__{rules: rules} = struct, index, rule) do
    %{struct | rules: List.insert_at(rules, index, rule)}
  end

  @doc """
  Iterates over all rules, calling the given function for each rule.
  """
  @spec each(t(), (rule() -> any())) :: :ok
  def each(%__MODULE__{rules: rules}, fun) do
    Enum.each(rules, fun)
  end

  # Private helper to apply rules recursively
  defp apply_rules([], word), do: word

  defp apply_rules([{pattern, replacement} | rest], word) do
    case apply_rule(word, pattern, replacement) do
      ^word -> apply_rules(rest, word)
      transformed -> transformed
    end
  end

  # Apply a single rule to a word
  defp apply_rule(word, pattern, replacement) when is_binary(pattern) do
    String.replace(word, pattern, replacement, global: false)
  end

  defp apply_rule(word, %Regex{} = pattern, replacement) do
    case Regex.replace(pattern, word, replacement, global: false) do
      ^word -> word
      result -> result
    end
  end
end

defmodule Drops.Inflector.Acronyms do
  @moduledoc """
  A set of acronyms for proper camelization and underscoring.

  This module manages acronym rules that affect how words are transformed
  during camelization and underscoring operations.
  """

  defstruct rules: %{}, regex: nil

  @type t :: %__MODULE__{rules: map(), regex: Regex.t()}

  @doc """
  Creates a new empty Acronyms struct.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
    |> define_regex_patterns()
  end

  @doc """
  Applies acronym rules to a word.

  If the word (lowercased) matches an acronym rule, returns the proper
  acronym form. Otherwise, capitalizes the word if capitalize is true.
  """
  @spec apply_to(t(), String.t(), keyword()) :: String.t()
  def apply_to(%__MODULE__{rules: rules}, word, opts \\ []) do
    capitalize = Keyword.get(opts, :capitalize, true)

    case Map.get(rules, String.downcase(word)) do
      nil -> if capitalize, do: String.capitalize(word), else: word
      acronym -> acronym
    end
  end

  @doc """
  Adds a new acronym rule.
  """
  @spec add(t(), String.t(), String.t()) :: t()
  def add(%__MODULE__{rules: rules} = struct, rule, replacement) do
    new_rules = Map.put(rules, rule, replacement)

    %{struct | rules: new_rules}
    |> define_regex_patterns()
  end

  @doc """
  Returns the regex pattern for matching acronyms.
  """
  @spec regex(t()) :: Regex.t()
  def regex(%__MODULE__{regex: regex}), do: regex

  # Private helper to define regex patterns
  defp define_regex_patterns(%__MODULE__{rules: rules} = struct) do
    regex =
      if Enum.empty?(rules) do
        # Never matches anything
        ~r/(?=a)b/
      else
        values = Map.values(rules)
        pattern = Enum.join(values, "|")
        Regex.compile!("(?:(?<=([A-Za-z\\d]))|\\b)(#{pattern})(?=\\b|[^a-z])")
      end

    %{struct | regex: regex}
  end
end

defmodule Drops.Inflector.Inflections do
  @moduledoc """
  Inflection rules container.

  This module manages all the inflection rules including plurals, singulars,
  uncountables, humans, and acronyms.
  """

  alias Drops.Inflector.{Rules, Acronyms}

  defstruct plurals: nil,
            singulars: nil,
            humans: nil,
            uncountables: nil,
            acronyms: nil

  @type t :: %__MODULE__{
          plurals: Rules.t(),
          singulars: Rules.t(),
          humans: Rules.t(),
          uncountables: MapSet.t(),
          acronyms: Acronyms.t()
        }

  @doc """
  Creates a new Inflections struct with default rules.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{
      plurals: Rules.new(),
      singulars: Rules.new(),
      humans: Rules.new(),
      uncountables: MapSet.new(),
      acronyms: Acronyms.new()
    }
    |> apply_defaults()
  end

  @doc """
  Adds a pluralization rule.
  """
  @spec plural(t(), String.t() | Regex.t(), String.t()) :: t()
  def plural(%__MODULE__{plurals: plurals} = struct, rule, replacement) do
    new_plurals = Rules.insert(plurals, 0, {rule, replacement})
    %{struct | plurals: new_plurals}
  end

  @doc """
  Adds a singularization rule.
  """
  @spec singular(t(), String.t() | Regex.t(), String.t()) :: t()
  def singular(%__MODULE__{singulars: singulars} = struct, rule, replacement) do
    new_singulars = Rules.insert(singulars, 0, {rule, replacement})
    %{struct | singulars: new_singulars}
  end

  @doc """
  Adds an irregular inflection (both plural and singular).
  """
  @spec irregular(t(), String.t(), String.t()) :: t()
  def irregular(%__MODULE__{} = struct, singular_word, plural_word) do
    # Remove from uncountables
    struct = remove_uncountable(struct, singular_word)
    struct = remove_uncountable(struct, plural_word)

    # Add irregular rules
    struct = add_irregular(struct, singular_word, plural_word, :plurals)
    add_irregular(struct, plural_word, singular_word, :singulars)
  end

  @doc """
  Adds uncountable words.
  """
  @spec uncountable(t(), [String.t()] | String.t()) :: t()
  def uncountable(%__MODULE__{uncountables: uncountables} = struct, words) when is_list(words) do
    new_uncountables = Enum.reduce(words, uncountables, &MapSet.put(&2, &1))
    %{struct | uncountables: new_uncountables}
  end

  def uncountable(%__MODULE__{} = struct, word) when is_binary(word) do
    uncountable(struct, [word])
  end

  @doc """
  Adds acronym rules.
  """
  @spec acronym(t(), [String.t()] | String.t()) :: t()
  def acronym(%__MODULE__{acronyms: acronyms} = struct, words) when is_list(words) do
    new_acronyms =
      Enum.reduce(words, acronyms, fn word, acc ->
        Acronyms.add(acc, String.downcase(word), word)
      end)

    %{struct | acronyms: new_acronyms}
  end

  def acronym(%__MODULE__{} = struct, word) when is_binary(word) do
    acronym(struct, [word])
  end

  @doc """
  Adds a human rule.
  """
  @spec human(t(), String.t() | Regex.t(), String.t()) :: t()
  def human(%__MODULE__{humans: humans} = struct, rule, replacement) do
    new_humans = Rules.insert(humans, 0, {rule, replacement})
    %{struct | humans: new_humans}
  end

  # Private helpers

  defp remove_uncountable(%__MODULE__{uncountables: uncountables} = struct, word) do
    new_uncountables = MapSet.delete(uncountables, word)
    %{struct | uncountables: new_uncountables}
  end

  defp add_irregular(%__MODULE__{} = struct, rule, replacement, target) do
    [head | tail] = String.graphemes(rule)
    tail_str = Enum.join(tail)
    pattern = Regex.compile!("(#{head})#{Regex.escape(tail_str)}$", "i")
    replacement_str = "\\1#{String.slice(replacement, 1..-1//1)}"

    case target do
      :plurals ->
        new_plurals = Rules.insert(struct.plurals, 0, {pattern, replacement_str})
        %{struct | plurals: new_plurals}

      :singulars ->
        new_singulars = Rules.insert(struct.singulars, 0, {pattern, replacement_str})
        %{struct | singulars: new_singulars}
    end
  end

  # Apply default inflection rules
  defp apply_defaults(struct) do
    struct
    |> apply_plural_defaults()
    |> apply_singular_defaults()
    |> apply_irregular_defaults()
    |> apply_uncountable_defaults()
    |> apply_acronym_defaults()
  end

  defp apply_plural_defaults(struct) do
    struct
    |> plural(~r/\z/, "s")
    |> plural(~r/s\z/i, "s")
    |> plural(~r/(ax|test)is\z/i, "\\1es")
    |> plural(~r/(.*)us\z/i, "\\1uses")
    |> plural(~r/(octop|vir|cact)us\z/i, "\\1i")
    |> plural(~r/(octop|vir)i\z/i, "\\1i")
    |> plural(~r/(alias|status)\z/i, "\\1es")
    |> plural(~r/(buffal|domin|ech|embarg|her|mosquit|potat|tomat)o\z/i, "\\1oes")
    |> plural(~r/(?<!b)um\z/i, "\\1a")
    |> plural(~r/([ti])a\z/i, "\\1a")
    |> plural(~r/sis\z/i, "ses")
    |> plural(~r/(.*)(?:([^f]))fe*\z/i, "\\1\\2ves")
    |> plural(~r/(hive|proof)\z/i, "\\1s")
    |> plural(~r/([^aeiouy]|qu)y\z/i, "\\1ies")
    |> plural(~r/(x|ch|ss|sh)\z/i, "\\1es")
    |> plural(~r/(stoma|epo)ch\z/i, "\\1chs")
    |> plural(~r/(matr|vert|ind)(?:ix|ex)\z/i, "\\1ices")
    |> plural(~r/([m|l])ouse\z/i, "\\1ice")
    |> plural(~r/([m|l])ice\z/i, "\\1ice")
    |> plural(~r/^(ox)\z/i, "\\1en")
    |> plural(~r/^(oxen)\z/i, "\\1")
    |> plural(~r/(quiz)\z/i, "\\1zes")
    |> plural(~r/(.*)non\z/i, "\\1na")
    |> plural(~r/(.*)ma\z/i, "\\1mata")
    |> plural(~r/(.*)(eau|eaux)\z/, "\\1eaux")
  end

  defp apply_singular_defaults(struct) do
    struct
    |> singular(~r/s\z/i, "")
    |> singular(~r/(n)ews\z/i, "\\1ews")
    |> singular(~r/([ti])a\z/i, "\\1um")
    |> singular(
      ~r/(analy|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)\z/i,
      "\\1\\2sis"
    )
    |> singular(~r/(^analy)(sis|ses)\z/i, "\\1sis")
    |> singular(~r/([^f])ves\z/i, "\\1fe")
    |> singular(~r/(hive)s\z/i, "\\1")
    |> singular(~r/(tive)s\z/i, "\\1")
    |> singular(~r/([lr])ves\z/i, "\\1f")
    |> singular(~r/([^aeiouy]|qu)ies\z/i, "\\1y")
    |> singular(~r/(s)eries\z/i, "\\1eries")
    |> singular(~r/(m)ovies\z/i, "\\1ovie")
    |> singular(~r/(ss)\z/i, "\\1")
    |> singular(~r/(x|ch|ss|sh)es\z/i, "\\1")
    |> singular(~r/([m|l])ice\z/i, "\\1ouse")
    |> singular(~r/(us)(es)?\z/i, "\\1")
    |> singular(~r/(o)es\z/i, "\\1")
    |> singular(~r/(shoe)s\z/i, "\\1")
    |> singular(~r/(cris|ax|test)(is|es)\z/i, "\\1is")
    |> singular(~r/(octop|vir)(us|i)\z/i, "\\1us")
    |> singular(~r/(alias|status)(es)?\z/i, "\\1")
    |> singular(~r/(ox)en/i, "\\1")
    |> singular(~r/(vert|ind)ices\z/i, "\\1ex")
    |> singular(~r/(matr)ices\z/i, "\\1ix")
    |> singular(~r/(quiz)zes\z/i, "\\1")
    |> singular(~r/(database)s\z/i, "\\1")
  end

  defp apply_irregular_defaults(struct) do
    struct
    |> irregular("person", "people")
    |> irregular("man", "men")
    |> irregular("human", "humans")
    |> irregular("child", "children")
    |> irregular("sex", "sexes")
    |> irregular("foot", "feet")
    |> irregular("tooth", "teeth")
    |> irregular("goose", "geese")
    |> irregular("forum", "forums")
  end

  defp apply_uncountable_defaults(struct) do
    uncountable(struct, [
      "hovercraft",
      "moose",
      "deer",
      "milk",
      "rain",
      "Swiss",
      "grass",
      "equipment",
      "information",
      "rice",
      "money",
      "species",
      "series",
      "fish",
      "sheep",
      "jeans"
    ])
  end

  defp apply_acronym_defaults(struct) do
    acronym(struct, [
      "API",
      "CSRF",
      "CSV",
      "DB",
      "HMAC",
      "HTTP",
      "JSON",
      "OpenSSL"
    ])
  end
end
