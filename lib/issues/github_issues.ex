defmodule Issues.GithubIssues do
  @moduledoc false

  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, :jsx.decode(body)}
  end
  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    {:error, "Not found"}
  end
  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, :jsx.decode(reason)}
  end
end