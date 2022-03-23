defmodule GenReport.Parser do
  @moduledoc """
  parse file into list of lists
  """
  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Stream.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
  end
end
