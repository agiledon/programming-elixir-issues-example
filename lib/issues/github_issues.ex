defmodule Issues.GithubIssues do
  @moduledoc false

  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, body}
  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}), do: {:error, "Not found"}
  defp handle_response({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
end