defmodule Issues.CLI do
  @default_count 4
  import Issues.TableFormater, only: [print_table_for_columns: 2]

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
"""

  def run(argv) do
    argv |> parse_args |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     alias:    [h:    :help   ])

    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
"""
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> convert_list_to_hashdicts
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def convert_list_to_hashdicts(list) do
    Enum.map(list, &Enum.into(&1, HashDict.new))
  end

  def sort_into_ascending_order(issues) do
    Enum.sort(issues, fn i1, i2 -> i1["created_at"] <= i2["created_at"] end)
  end
end