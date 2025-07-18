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
