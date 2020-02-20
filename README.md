# Elixir is harder than I thought! 

My code is a bit of hack, it is the first time doing anything substantial with Elixir. 

Unfortunately I could not find a way to manipulate the images on the fly, without 
touching the file system. That would have been much cleaner. I also have not 
accounted for cleaning up the temporary files.

If you would like something cleaner, I'll do a version in Ruby. Please let me know.


Two endpoints:

1. An endpoint which will validate your file is an image and return key metadata (filetype, size, dimensions)

http://localhost:4000/api/info/?image-url=https://i.imgur.com/InTf1LQ.jpg

```
%Mogrify.Image{animated: false, buffer: nil, dirty: %{}, ext: ".jpg", format: "jpeg", frame_count: 1, height: 2592, operations: [], path: "/Users/leocampbell/Sites/test_app/assets/static/images/InTf1LQ.jpg", width: 3888}
```

2. An endpoint which will return a resized version of your image file

http://localhost:4000/api/thumbnail/?image-url=http://clipart-library.com/images/yTkKaLGAc.png

Image resized to 100x100.

![Screenshot](elixir_endpoint_2.png)

```elixir 
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
```


