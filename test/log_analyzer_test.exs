defmodule LogAnalyzerTest do
  use ExUnit.Case
  doctest LogAnalyzer

  def log_line_stub() do
    %LogAnalyzer.LogLine{
      ip: "93.180.71.3",
      timestamp: "[17/May/2015:08:05:32 +0000]",
      request: "GET /downloads/product_1 HTTP/1.1",
      http_status: "304",
      bytes: "0",
      ua: "Debian APT-HTTP/1.3 (0.8.16~exp12ubuntu10.21)"
    }
  end

  def line_stub() do
    ~s(93.180.71.3 - - [17/May/2015:08:05:32 +0000] "GET /downloads/product_1 HTTP/1.1" 304 0 "-" "Debian APT-HTTP/1.3 \(0.8.16~exp12ubuntu10.21\)")
  end

  test "LogAnalyzer.from_lines" do
    lines = [
      line_stub(),
      line_stub()
    ]

    list = [
      log_line_stub(),
      log_line_stub()
    ]

    assert LogAnalyzer.from_lines(lines) == list
  end

  test "LogAnalyzer.histogram_from" do
    log_lines = [
      log_line_stub(),
      log_line_stub()
    ]

    histogram = %LogAnalyzer.Histogram{
      data: %{"93.180.71.3" => 2}
    }

    assert LogAnalyzer.histogram_from(log_lines, :ip) == histogram
  end

  test "LogAnalyzer.Histogram.from_list" do
    assert LogAnalyzer.Histogram.from_list([], nil) == %LogAnalyzer.Histogram{}

    list = [
      log_line_stub(),
      log_line_stub()
    ]

    histogram = %LogAnalyzer.Histogram{
      data: %{"93.180.71.3" => 2}
    }

    assert LogAnalyzer.Histogram.from_list(list, :ip) == histogram
  end

  test "Histogram.increment_value" do
    histogram = %LogAnalyzer.Histogram{data: %{"0" => 1}}

    assert LogAnalyzer.Histogram.increment_value(histogram, "0") == %LogAnalyzer.Histogram{
             data: %{"0" => 2}
           }
  end

  test "Histogram.get_count" do
    histogram = %LogAnalyzer.Histogram{data: %{"0" => 1}}

    assert LogAnalyzer.Histogram.get_count(histogram, "0") == {:ok, 1}
  end

  test "Histogram.get_max_value" do
    histogram = %LogAnalyzer.Histogram{data: %{"0" => 1, "1" => 2}}

    assert LogAnalyzer.Histogram.get_max_value(histogram) == {"1", 2}
  end

  test "LogLine.from_line" do
    line = line_stub()

    assert LogAnalyzer.LogLine.from_line(line) == %LogAnalyzer.LogLine{
             ip: "93.180.71.3",
             timestamp: "[17/May/2015:08:05:32 +0000]",
             request: "GET /downloads/product_1 HTTP/1.1",
             http_status: "304",
             bytes: "0",
             ua: "Debian APT-HTTP/1.3 (0.8.16~exp12ubuntu10.21)"
           }
  end
end
