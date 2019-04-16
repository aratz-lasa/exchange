good = %Good{name: "good", price: 12, description: "description"}
Map.delete(good, :__struct__) |> Map.keys |> Enum.sort
good |> Map.delete(:__struct__) |> Map.to_list |> List.keysort(0) |> Keyword.values |> List.insert_at(1, good.__struct__) 
