defmodule ElixirHashCompareTest do
  use ExUnit.Case
  import ElixirHashCompare
  doctest ElixirHashCompare

  test "compare when two simple hashes are the same" do
    first_map = %{ first: "first value" }
    same_map = %{ first: "first value" }
    assert compare(first_map, same_map, "deep") == %{}
  end

  test "when a key has been added" do
    first_map = %{ first: "first value" }
    second_map = %{ first: "first value", second: "second value" }

    assert compare(first_map, second_map, "deep") == %{
      added: %{
        second: "second value"
      }
    }
  end

  test "when a key has been removed" do
    first_map = %{ first: "first value", second: "second value" }
    second_map = %{ first: "first value" }

    assert compare(first_map, second_map, "deep") == %{
      removed: %{
        second: "second value"
      }
    }
  end

  test "when a key has been changed" do
    first_map = %{ first: "first value" }
    second_map = %{ first: "new value" }
    assert compare(first_map, second_map, "deep") == %{
      changed: %{
        first: %{
          before: "first value",
          after: "new value"
        }
      }
    }
  end

  test "when a subkey has changed" do
    first_map = %{ first: %{
        second: "first value"
      }
    }

    second_map = %{ first: %{
        second: "new value"
      }
    }

    assert compare(first_map, second_map, "deep") == %{
      changed: %{
        first: %{
          changed: %{
            second: %{
              before: "first value",
              after: "new value"
            }
          }
        }
      }
    }
  end

  test "when a subkey has changed and using shallow checks" do
    first_map = %{ first: %{
        second: "first value"
      }
    }

    second_map = %{ first: %{
        second: "new value"
      }
    }

    assert compare(first_map, second_map, "shallow") == %{
      changed: %{
        first: %{
          before: %{ second: "first value" },
          after: %{ second: "new value" }
        }
      }
    }
  end

  test "when a key is changed from one value type to another" do
    first_map = %{ first: "first" }
    second_map = %{ first: 1 }

    assert compare(first_map, second_map, "shallow") == %{
      changed: %{
        first: %{
          before: "first",
          after: 1
        }
      }
    }
  end

  test "when a list is the same" do
    first_map = %{ first: ["one", 1] }
    same_map = %{ first: ["one", 1] }
    assert compare(first_map, same_map, "shallow") == %{}
  end

  test "when a list has changed" do
    first_map = %{ first: ["one", 1] }
    same_map = %{ first: ["one", 2] }
    assert compare(first_map, same_map, "shallow") == %{
      changed: %{
        first: %{
          before: ["one", 1],
          after: ["one", 2]
        }
      }
    }
  end

  test "when a list of maps has changed" do
    first_map = %{ first: [%{first: "first"}] }
    second_map = %{ first: [%{first: "new"}] }

    assert compare(first_map, second_map, "shallow") == %{
      changed: %{
        first: %{
          before: [%{first: "first"}],
          after: [%{first: "new"}]
        }
      }
    }
  end
end
