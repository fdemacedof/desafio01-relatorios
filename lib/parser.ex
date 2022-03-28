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
    |> trim_line()
  end

  defp trim_line([name, hours, day, month, year]) do
    [name, hours, day, month, year] = [
      String.downcase(name),
      String.to_integer(hours),
      String.to_integer(day),
      get_month(month),
      String.to_integer(year)
    ]

    [name, hours, day, month, year]
  end

  defp get_month(num) do
    months = %{
      "1" => "janeiro",
      "2" => "fevereiro",
      "3" => "março",
      "4" => "abril",
      "5" => "maio",
      "6" => "junho",
      "7" => "julho",
      "8" => "agosto",
      "9" => "setembro",
      "10" => "outubro",
      "11" => "novembro",
      "12" => "dezembro"
    }

    months[num]
  end
end
