defmodule FileCleaner do
  use Application

  def start(_type, _args) do
    IO.puts("File cleaner started")

    seven_days_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-7, :day)

    "config.conf"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.reject(fn line -> line == "" or String.starts_with?(line, "#") end)
    |> Enum.each(fn pattern ->
      IO.puts("\nPattern: #{pattern}")
      Path.wildcard(pattern)
      |> Enum.each(fn filename ->
        IO.puts("File: #{filename}")
        stat = File.stat!(filename)
        {:ok, ctime_naive} = NaiveDateTime.from_erl(stat.ctime)
        if NaiveDateTime.compare(ctime_naive, seven_days_ago) === :lt do
          IO.puts("Deleting old file #{filename} (Created at #{ctime_naive})")
        end
      end)
    end)
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
