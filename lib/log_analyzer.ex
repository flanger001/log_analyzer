defmodule LogAnalyzer do
  defmodule Histogram do
    @moduledoc false
    @type t() :: %__MODULE__{}

    defstruct data: %{}

    @doc """
    Takes a list of LogLines and a key and builds a Histogram from th
    """
    @spec from_list([t], atom) :: t
    def from_list(list, key) when is_atom(key) do
      list
      |> Enum.reduce(%__MODULE__{}, fn x, acc ->
        {:ok, value} = Map.fetch(x, key)
        increment_value(acc, value)
      end)
    end

    @doc """
    Takes a Histogram and increments the count for a particular value.
    If that value doesn't exist, it starts with 1.
    """
    @spec increment_value(t, String.t()) :: t
    def increment_value(acc = %__MODULE__{}, value) do
      %{acc | data: Map.update(acc.data, value, 1, &(&1 + 1))}
    end

    @doc """
    Takes a Histogram and returns the count for a particular value
    """
    @spec get_count(t, String.t()) :: {:ok, map}
    def get_count(histogram = %__MODULE__{}, value) when is_binary(value) do
      Map.fetch(histogram.data, value)
    end

    @doc """
    Takes a Histogram and returns the value with the highest count
    """
    @spec get_max_value(t) :: map
    def get_max_value(histogram = %__MODULE__{}) do
      Enum.max_by(histogram.data, fn {_, v} -> v end)
    end
  end

  defmodule LogLine do
    @type t :: %__MODULE__{}
    @pattern ~r/(?<ip>.*) - - (?<timestamp>\[.*\]) "(?<request>.*)" (?<http_status>\d{3}) (?<bytes>\d.*) "(?<referrer>.*)" "(?<ua>.*)"/

    defstruct [:ip, :timestamp, :request, :http_status, :bytes, :ua]

    @doc """
    Takes a string and returns a LogLine
    """
    @spec from_line(String.t()) :: t
    def from_line(line) when is_binary(line) do
      matches = Regex.named_captures(@pattern, line)

      %__MODULE__{
        ip: matches["ip"],
        timestamp: matches["timestamp"],
        request: matches["request"],
        http_status: matches["http_status"],
        bytes: matches["bytes"],
        ua: matches["ua"]
      }
    end
  end

  @doc """
  Opens a file given by a string filename and streams it to `from_lines`
  """
  @spec read_file(String.t()) :: [LogAnalyzer.Histogram.t()]
  def read_file(filename) do
    File.stream!(filename)
    |> from_lines
  end

  @doc """
  Takes a list of strings maps each to a LogLine
  """
  @spec from_lines(File.Stream.t()) :: [LogAnalyzer.Histogram.t()]
  def from_lines(lines) do
    Enum.map(lines, &LogAnalyzer.LogLine.from_line/1)
  end

  @doc """
  Takes a list of LogLines and a key and builds a Histogram from them
  """
  @spec histogram_from([LogAnalyzer.LogLine.t()], atom) :: LogAnalyzer.Histogram.t()
  def histogram_from(list, key) when is_atom(key) do
    LogAnalyzer.Histogram.from_list(list, key)
  end
end
