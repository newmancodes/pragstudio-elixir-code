defmodule Servy.Handler do
    def handle(request) do
        request
        |> parse
        |> rewrite_path
        |> log
        |> route
        |> track
        |> format_response
    end

    defp parse(request) do
        [ method, path, _ ] =
            request
            |> String.split("\n")
            |> List.first
            |> String.split(" ")
        %{ method: method,
           path: path,
           resp_body: "",
           status: nil }
    end

    defp log(conv), do: IO.inspect conv

    defp rewrite_path(%{ path: "/wildlife" } = conv) do
        %{ conv | path: "/wildthings" }
    end

    defp rewrite_path(conv), do: conv

    defp route(%{ method: "GET", path: "/wildthings" } = conv) do
        %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
    end

    defp route(%{ method: "GET", path: "/bears" } = conv) do
        %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
    end

    defp route(%{ method: "GET", path: "/bears/" <> id } = conv) do
        %{ conv | status: 200, resp_body: "Bear #{id}" }
    end

    defp route(%{ method: "DELETE", path: "/bears/" <> id } = conv) do
        %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!" }
    end

    defp route(%{ path: path } = conv) do
        %{ conv | status: 404, resp_body: "No #{path} here!" }
    end

    defp track(%{ status: 404, path: path } = conv) do
        IO.puts "Warning: #{path} is on the loose!"
        conv
    end

    defp track(conv), do: conv

    defp format_response(conv) do
        """
        HTTP/1.1 #{ conv.status } #{ status_reason(conv.status) }
        Content-Type: text/html
        Content-Length: #{ byte_size(conv.resp_body)}

        #{ conv.resp_body }
        """
    end

    defp status_reason(code) do
      %{
        200 => "OK",
        201 => "Created",
        401 => "Unauthprized",
        403 => "Forbidden",
        404 => "Not Found",
        500 => "Internal Server Error"
      }[code]
    end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response

response = Servy.Handler.handle(request)
IO.puts response

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: *.*

"""

response = Servy.Handler.handle(request)
IO.puts response
