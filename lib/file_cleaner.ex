defmodule FileCleaner do
  use Application
  require Logger

  def start(_type, _args) do
    clean_files()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def clean_files do
    Logger.info("File cleaner started")

    current_time = toLocalTime(NaiveDateTime.utc_now())
    Logger.info("current time: #{inspect(current_time)}")
    seven_days_ago = current_time |> NaiveDateTime.add(-7, :day)

    "config.conf"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.reject(fn line -> line == "" or String.starts_with?(line, "#") end)
    |> Enum.each(fn pattern ->
      Logger.info("\nPattern: #{pattern}")

      Path.wildcard(pattern)
      |> Enum.each(fn filename ->
        Logger.info("File: #{filename}")

        case File.stat(filename) do
          {:ok, stat} ->
            mtime = toLocalTime(NaiveDateTime.from_erl!(stat.mtime))

            if NaiveDateTime.compare(mtime, seven_days_ago) === :lt do
              Logger.info("Deleting old file #{filename} (Created at #{mtime})")
            end

          {:error, reason} ->
            Logger.error("Stat failed for #{filename}: #{inspect(reason)}")
        end
      end)
    end)
  end

  defp toLocalTime(time) do
    local_time = NaiveDateTime.from_erl!(:calendar.local_time())
    utc_time = NaiveDateTime.from_erl!(:calendar.universal_time())
    offset = NaiveDateTime.diff(local_time, utc_time)
    Logger.debug("offset #{inspect(offset)}")
    NaiveDateTime.add(time, offset)
  end
end
