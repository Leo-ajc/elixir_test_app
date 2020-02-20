defmodule TestAppWeb.Api.ImageController do
  use TestAppWeb, :controller
  import Mogrify
  
  def info(conn, params) do
    uri = URI.parse(params["image-url"])
    file_path = "assets/static/images/#{:rand.uniform(100000)}"

    %HTTPoison.Response{body: body} = HTTPoison.get!(params["image-url"])
    File.write!(file_path, body)

    text conn, Mogrify.open(file_path) |> Mogrify.verbose |> Kernel.inspect() 
  end

  def thumbnail(conn, params) do
    %HTTPoison.Response{body: body, headers: headers} = HTTPoison.get!(params["image-url"])
    headers = Enum.into headers, %{}
    file_path = "assets/static/images/#{:rand.uniform(100000)}"
    File.write!(file_path, body)

    Mogrify.open(file_path)
    |> Mogrify.resize_to_fill("100x100")
    |> Mogrify.save(path: file_path)

    conn
    |> put_resp_content_type(headers["Content-Type"])
    |> send_file(200, file_path)
  end

end
