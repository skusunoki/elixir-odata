defmodule OData do
  @moduledoc """
  See the README.
  """
  @typep call_result :: {:ok, OData.Response.t()} | {:error, any}
  alias OData.{Request, Response, HTTP, Query}

  @doc """

  """
  @spec build_query(String.t()) :: Query.t()
  @spec build_query(String.t(), String.t()) :: Query.t()
  defdelegate build_query(entity), to: Query, as: :build
  def build_query(entity, service_root), do: Query.build( service_root, entity )

  @doc """

  """
  @spec set_query_params( Query.t, Keyword.t ) :: Query.t
  defdelegate set_query_params(query, params), to: Query, as: :set_params

  @doc """

  """
  @spec build_request(Query.t, String.t) :: Request.t
  defdelegate build_request(query, url), to: Request, as: :build

  @doc """
  Calls the OData API.
  """
  @spec call(Request.t) :: call_result
  def call(%Request{} = request) do
    request
    |> HTTP.get
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Response.build(body)
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, {:status, code, body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {:http, reason}}
    end
  end

  @spec call(String.t, String.t, Keyword.t) :: call_result
  def call(entity, url, params \\ [])
  when is_binary(entity) and is_binary(url) and is_list(params) do
    entity
    |> build_query()
    |> set_query_params(params)
    |> build_request(url)
    |> call
  end

end
