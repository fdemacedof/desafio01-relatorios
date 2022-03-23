defmodule GenReport do
  @moduledoc """
  Generates report using given file
  """
  alias GenReport.Parser

  def build() do
    "gen_report.csv"
    |> Parser.parse_file()
    |> report_acc()

    # |> Enum.map(fn line ->
    #   %{
    #     all_hours: %{},
    #     hours_per_month: %{},
    #     hours_per_year: %{}
    #   }
    # end)
  end

  defp sum_values([name, hours, day, month, year], report) do
  end

  def report_acc(list) do
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
