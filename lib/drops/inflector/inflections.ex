defmodule Drops.Inflector.Inflections do
  @moduledoc """
  Inflection rules container.

  This module manages all the inflection rules including plurals, singulars,
  uncountables, humans, and acronyms.
  """

  alias Drops.Inflector.{Rules, Acronyms}

  alias __MODULE__

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
  def new(), do: new([])

  @spec new(keyword()) :: t()
  def new(opts) do
    %__MODULE__{
      plurals: Rules.new(),
      singulars: Rules.new(),
      humans: Rules.new(),
      uncountables: MapSet.new(),
      acronyms: Acronyms.new()
    }
    |> apply_defaults()
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
