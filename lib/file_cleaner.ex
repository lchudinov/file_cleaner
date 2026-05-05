defmodule FileCleaner do
  use Application

  def start(_type, _args) do
    clean_files()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def clean_files do
    IO.puts("File cleaner started")

    current_time = NaiveDateTime.utc_now()
    IO.puts("current time UTC: #{inspect(current_time)}")
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

        case File.stat(filename) do
          {:ok, stat} ->
            {:ok, mtime} = NaiveDateTime.from_erl(stat.mtime)

            if NaiveDateTime.compare(mtime, seven_days_ago) === :lt do
              IO.puts("Deleting old file #{filename} (Created at #{mtime} UTC)")
            end

          {:error, reason} ->
            IO.puts("Stat failed for #{filename}: #{inspect(reason)}")
        end
      end)
    end)
  end
end
