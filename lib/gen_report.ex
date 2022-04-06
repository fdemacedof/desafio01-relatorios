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

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(file_names) do
    file_names
    |> Task.async_stream(&build/1)
    |> Enum.map(& &1)
    |> Enum.reduce(report_acc(), fn result, report -> sum_reports(report, result) end)
  end

  defp sum_values([name, hours, day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    [name, hours, _day, month, year] = [
      name,
      hours,
      day,
      month,
      year
    ]

    # sum over all hours
    all_hours = put_in(all_hours[name], all_hours[name] + hours)
    # sum hours per user per month
    hours_per_month =
      put_in(
        hours_per_month[name][month],
        hours_per_month[name][month] + hours
      )

    # sum hours per user per year
    hours_per_year = put_in(hours_per_year[name][year], hours_per_year[name][year] + hours)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  def sum_reports(
        %{
          "all_hours" => all_hours1,
          "hours_per_month" => hours_per_month1,
          "hours_per_year" => hours_per_year1
        },
        {:ok,
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }}
      ) do
    all_hours = Map.merge(all_hours1, all_hours2, fn _key, value1, value2 -> value1 + value2 end)
    hours_per_month = merge_nested_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_nested_maps(hours_per_year1, hours_per_year2)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  def merge_nested_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, user1, user2 ->
      Map.merge(user1, user2, fn _key, value1, value2 -> value1 + value2 end)
    end)
  end

  def report_acc() do
    list =
      "gen_report.csv"
      |> Parser.parse_file()

    users = get_users(list)
    users_map = build_users_map(users)
    users_month_map = build_users_month_map(users)
    users_years_map = build_users_years_map(list, users)

    %{
      "all_hours" => users_map,
      "hours_per_month" => users_month_map,
      "hours_per_year" => users_years_map
    }
  end

  defp get_users(list) do
    list
    |> Enum.map(fn [head | _tail] -> head end)
  end

  defp build_users_map(users) do
    users
    |> Enum.map(fn x -> {x, 0} end)
    |> Map.new()
  end

  defp build_users_month_map(users) do
    months = %{
      "janeiro" => 0,
      "fevereiro" => 0,
      "março" => 0,
      "abril" => 0,
      "maio" => 0,
      "junho" => 0,
      "julho" => 0,
      "agosto" => 0,
      "setembro" => 0,
      "outubro" => 0,
      "novembro" => 0,
      "dezembro" => 0
    }

    users
    |> Enum.map(fn x -> {x, months} end)
    |> Map.new()
  end

  defp build_users_years_map(list, users) do
    years =
      list
      |> Enum.map(fn [_name, _hours, _day, _month, year] -> year end)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(fn x -> {x, 0} end)
      |> Map.new()

    users
    |> Enum.map(fn x -> {x, years} end)
    |> Map.new()
  end
end
