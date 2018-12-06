defmodule Church do
  @moduledoc """
  Documentation for Church.
  """

  @doc """
  Encode numerals in accordance with https://en.wikipedia.org/wiki/Church_encoding

  ## Examples

      iex> Church.encode(0).(:arg)
      :arg

  """
  def encode(0), do: fn arg -> arg end
end
