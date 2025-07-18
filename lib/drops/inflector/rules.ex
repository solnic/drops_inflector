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
