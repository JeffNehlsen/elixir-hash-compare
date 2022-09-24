defmodule ElixirHashCompare do
  @moduledoc """
  Compares two hashes

  Original instructions:
  You have 2 hashes. You are looking for the difference between the 2. What was added or removed or if the hash is the same.

  Hash only have string keys
  Hash only have string, boolean, number, array or hash as value
  Compare should have an option for deep or shallow compare
  Compare should list the difference for keys and values
  """

  @doc """
  compare/3
  Arguments:
  1: first hash (keys must be strings, values can string, boolean, number, array, or hash as a type)
  2: second hash (keys must be strings, values can string, boolean, number, array, or hash as a type)
  3. style: deep OR shallow

  Outputs:
    A hash detailing the differences between the two hashes.
    Deep style will run all changed maps through compare_map/3 to get more details on the changes
    Shallow style will simply return changed maps in the before and after style

    Example output:
    %{
      added: %{
        added_key1: "added value",
        added_key2: "added value",
      },
      removed: %{
        removed_key1: "removed value 1",
        removed_key2: "removed value 2"
      },
      changed: %{
        changed_key1: %{
          before: "before value",
          after: "after value"
        },
        changed_array: %{
          before: ["one", 1, :one],
          after: ["two", 2, :two]
        },
        changed_hash: %{
          before: %{ first_key: "first value" },
          after: %{ first_key: "new value" }
        }
      }
    }

    If using deep style, changed hashes will have more detail:
    %{
      changed_hash: %{
        added: %{ added_key1: "added value1" },
        removed: %{ removed_key1: "removed value1" },
        chnaged: %{
          changed_key1: %{
            before: "before change",
            after: "after change"
          }
        }
      }
    }
  """
  def compare(same, same, _style) do
    %{}
  end

  def compare(first_map, second_map, style) do
    compare_map(first_map, second_map, style)
  end

  defp compare_map(first_map, second_map, style) do
    first_map_keys = Map.keys(first_map)
    second_map_keys = Map.keys(second_map)

    added_keys = second_map_keys -- first_map_keys
    removed_keys = first_map_keys -- second_map_keys
    same_keys = MapSet.intersection(MapSet.new(first_map_keys), MapSet.new(second_map_keys))

    added_map = Map.take(second_map, added_keys)
    removed_map = Map.take(first_map, removed_keys)
    changed_map = Enum.reduce(same_keys, %{}, fn (key, changed) ->
      before_value = first_map[key]
      after_value = second_map[key]

      changed_map_if_different(changed, key, before_value, after_value, style)
    end)

    %{}
    |> add_to_result_if_not_empty(:added, added_map)
    |> add_to_result_if_not_empty(:removed, removed_map)
    |> add_to_result_if_not_empty(:changed, changed_map)
  end

  # Empty values will just return the initial map
  defp add_to_result_if_not_empty(result, _key, value) when value == %{}, do: result

  # Non-empty values will be added to the result with the given key
  defp add_to_result_if_not_empty(result, key, value), do: Map.put(result, key, value)

  # When two values are the same (note the pattern match to match v1 twice), return the unmodified changed_map
  defp changed_map_if_different(changed_map, _key, v1, v1, _style), do: changed_map

  # When two maps are deep compared, run them through compare_map to get a deep readout of their differences
  defp changed_map_if_different(changed_map, key, v1, v2, "deep") when is_map(v1) and is_map(v2) do
    add_to_result_if_not_empty(changed_map, key, compare_map(v1, v2, "deep"))
  end

  # Shallow compare and default option when the value are different: just give a before and after result
  defp changed_map_if_different(changed_map, key, v1, v2, _style) do
    Map.put(changed_map, key, %{
      before: v1,
      after: v2,
    })
  end
end
