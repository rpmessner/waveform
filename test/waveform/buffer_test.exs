defmodule Waveform.BufferTest do
  use ExUnit.Case, async: true

  alias Waveform.Buffer

  # Buffer is already started by the application supervisor
  # We test the API without actual SuperCollider

  describe "buffer allocation" do
    test "read returns buffer number" do
      # This won't actually load a file (no SuperCollider), but tests the API
      {:ok, buf_num} = Buffer.read("/tmp/nonexistent.wav")
      assert is_integer(buf_num)
      assert buf_num >= 1000

      # Clean up
      Buffer.free(buf_num)
    end

    test "read with options returns buffer number" do
      {:ok, buf_num} =
        Buffer.read("/tmp/nonexistent.wav",
          start_frame: 44_100,
          num_frames: 88_200
        )

      assert is_integer(buf_num)

      Buffer.free(buf_num)
    end

    test "read with channels option returns buffer number" do
      {:ok, buf_num} = Buffer.read("/tmp/nonexistent.wav", channels: [0])
      assert is_integer(buf_num)

      Buffer.free(buf_num)
    end

    test "allocate returns buffer number" do
      {:ok, buf_num} = Buffer.allocate(88_200, 2)
      assert is_integer(buf_num)
      assert buf_num >= 1000

      Buffer.free(buf_num)
    end

    test "sequential buffer numbers" do
      {:ok, buf1} = Buffer.read("/tmp/test1.wav")
      {:ok, buf2} = Buffer.read("/tmp/test2.wav")
      {:ok, buf3} = Buffer.allocate(1000, 1)

      assert buf2 == buf1 + 1
      assert buf3 == buf2 + 1

      Buffer.free(buf1)
      Buffer.free(buf2)
      Buffer.free(buf3)
    end
  end

  describe "buffer management" do
    test "list returns allocated buffer numbers" do
      {:ok, buf1} = Buffer.read("/tmp/test1.wav")
      {:ok, buf2} = Buffer.read("/tmp/test2.wav")

      buffers = Buffer.list()
      assert buf1 in buffers
      assert buf2 in buffers

      Buffer.free(buf1)
      Buffer.free(buf2)
    end

    test "free removes buffer from list" do
      {:ok, buf_num} = Buffer.read("/tmp/test.wav")
      assert buf_num in Buffer.list()

      :ok = Buffer.free(buf_num)
      refute buf_num in Buffer.list()
    end

    test "free returns error for unknown buffer" do
      assert {:error, :not_found} = Buffer.free(999_999)
    end

    test "free_all clears all buffers" do
      {:ok, _buf1} = Buffer.read("/tmp/test1.wav")
      {:ok, _buf2} = Buffer.read("/tmp/test2.wav")

      assert length(Buffer.list()) >= 2

      :ok = Buffer.free_all()

      # List should be empty (for buffers we allocated)
      assert Buffer.list() == []
    end

    test "zero returns ok for known buffer" do
      {:ok, buf_num} = Buffer.allocate(1000, 1)
      assert :ok = Buffer.zero(buf_num)

      Buffer.free(buf_num)
    end

    test "zero returns error for unknown buffer" do
      assert {:error, :not_found} = Buffer.zero(999_999)
    end
  end
end
