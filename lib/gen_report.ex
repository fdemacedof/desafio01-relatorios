defmodule GenReport do
  @moduledoc """
  Generates report using given file
  """
  alias GenReport.Parser

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  defp sum_values([name, hours, day, month, year], %{
         all_hours: all_hours,
         hours_per_month: hours_per_month,
         hours_per_year: hours_per_year
       }) do
    [name, hours, _day, month, year] = [
      String.to_atom(name),
      String.to_integer(hours),
      day,
      get_month(month),
      String.to_atom(year)
    ]

    # sum over all hours
    all_hours = put_in(all_hours[name], all_hours[name] + hours)
    # sum hours per user per month
    hours_per_month = put_in(hours_per_month[name][month], hours_per_month[name][month] + hours)
    # sum hours per user per year
    hours_per_year = put_in(hours_per_year[name][year], hours_per_year[name][year] + hours)

    %{
      all_hours: all_hours,
      hours_per_month: hours_per_month,
      hours_per_year: hours_per_year
    }
  end

  def report_acc() do
    list =
      "gen_report.csv"
      |> Parser.parse_file()

    users = get_users(list)
    users_map = build_users_map(users)
    users_month_map = build_users_month_map(users)
    users_years_map = build_users_years_map(list, users)

    %{all_hours: users_map, hours_per_month: users_month_map, hours_per_year: users_years_map}
  end

  defp get_users(list) do
    list
    |> Enum.map(fn [head | _tail] -> head end)
  end

  defp build_users_map(users) do
    users
    |> Enum.map(fn x -> {String.to_atom(x), 0} end)
    |> Map.new()
  end

  defp build_users_month_map(users) do
    months = %{
      janeiro: 0,
      fevereiro: 0,
      março: 0,
      abril: 0,
      maio: 0,
      junho: 0,
      julho: 0,
      agosto: 0,
      setembro: 0,
      outubro: 0,
      novembro: 0,
      dezembro: 0
    }

    users
    |> Enum.map(fn x -> {String.to_atom(x), months} end)
    |> Map.new()
  end

  defp get_month(num) do
    months = %{
      "1" => :janeiro,
      "2" => :fevereiro,
      "3" => :março,
      "4" => :abril,
      "5" => :maio,
      "6" => :junho,
      "7" => :julho,
      "8" => :agosto,
      "9" => :setembro,
      "10" => :outubro,
      "11" => :novembro,
      "12" => :dezembro
    }

    months[num]
  end

  defp build_users_years_map(list, users) do
    years =
      list
      |> Enum.map(fn [_name, _hours, _day, _month, year] -> year end)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(fn x -> {String.to_atom(x), 0} end)
      |> Map.new()

    users
    |> Enum.map(fn x -> {String.to_atom(x), years} end)
    |> Map.new()
  end
end
