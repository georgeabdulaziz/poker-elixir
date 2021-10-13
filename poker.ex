defmodule Poker do
	
	
	def deal(arr)do
		[a1,a2,a3,a4|ground] = arr
		player1 = [a1,a3]
		player2 = [a2,a4]
		best1 = bestHand(player1,ground)
		best2 = bestHand(player2,ground)
		result = handCompare(best1,best2)
		case result do
			1 -> handToStringSorted(best1,pokerEval(best1))
			-1 -> handToStringSorted(best2,pokerEval(best2))
			_ -> handToStringSorted(best1,pokerEval(best1))
		end
	end
	
	
	def handToStringSorted(arr,condition)do
		result = Enum.reduce(arr, [], fn item, result -> result ++ [cardToString(item)] end)
		#IO.puts condition
		result =
			case condition do
				180 -> result
				101 -> result
				80 -> result
				1 -> result
				_ -> excludeSingles(result)
				
			end
		result = completeHandSortFinal(result)
		
	end
	
	
	def completeHandSortFinal(arr) do
		newArr = handSortFinal(arr,arr)
		cond do
			arr != newArr -> completeHandSortFinal(newArr)
			true -> newArr
		end
	end
	
	def handSortFinal([name1,name2| tail],arr) do

		itemStrLen1 = String.length(name1)
		itemSuit1 = String.slice(name1, (itemStrLen1-1)..(itemStrLen1))
		itemRank1 = String.to_integer(String.slice(name1, 0..(itemStrLen1-2)))
		itemRank1 =
			cond do
				(itemRank1 == 1) -> 111
				true -> itemRank1
			end
		itemStrLen2 = String.length(name2)
		itemSuit2 = String.slice(name2, (itemStrLen2-1)..(itemStrLen2))
		itemRank2 = String.to_integer(String.slice(name2, 0..(itemStrLen2-2)))
		itemRank2 =
			cond do
				(itemRank2 == 1) -> 111
				true -> itemRank2
			end
			
		x = 
			cond do
				itemRank1>itemRank2 -> name2
				itemRank1<itemRank2 -> name1
				itemRank1==itemRank2 -> cond do 
											itemSuit1>itemSuit2 -> name2
											itemSuit1<itemSuit2 -> name1
											true -> name2
										end
				true -> name2
			end
		new = arr -- [x]
		[x] ++ handSortFinal(new, new)
	end
	
	def handSortFinal(arr,arr), do: arr
	def handSortFinal(_,_,_), do: [] 
	
	
	

	
	def arrayToDictFinal(array1) do
		dictRank =
			Enum.reduce(array1, %{}, fn itemString, dictRank -> 
				itemStrLen = String.length(itemString)
				itemRank = String.slice(itemString, 0..(itemStrLen-2))
				itemRank = String.to_integer(itemRank)
				#	cond do
				#		(itemRank == "1") -> 111
				#		true -> String.to_integer(itemRank)
				#	end
				Map.update(dictRank, itemRank, 1, &(&1 + 1)) 
		end)
	end
	
	def excludeSingles(arr)do
		dict = arrayToDictFinal(arr)
		#IO.inspect Map.to_list(dict)

		result =
			Enum.reduce(arr, [], fn item, result -> 
					itemStrLen = String.length(item)
					itemRank = String.to_integer(String.slice(item, 0..(itemStrLen-2)))
					#IO.puts dict[itemRank]
					cond do
						dict[itemRank]==1 -> result++[]
						true ->  result++[item]
					end
			end)

	end
	
	
	def bestHand(hand, ground) do
		[firstHand|secondHand] = hand
		fir = singleHandList(1, 10, [firstHand], ground, [])
		#IO.inspect fir
		sec = singleHandList(1, 10, secondHand, ground, [])
		#IO.inspect sec
		third = singleHandList0(2 ,6, hand, ground, [], 5)
		
		
		dictOfPermutation = fir ++ sec ++ third ++ [ground]
		final =  Enum.reduce( dictOfPermutation, [], fn item, final -> final ++ [Enum.sort(item, :asc)] end)
		#IO.inspect final
		
		permMap = Enum.frequencies(final)
		#IO.inspect Map.to_list(permMap)
		
		finalPerms = Enum.reduce( permMap, [], fn{k,v}, finalPerms -> finalPerms ++ [k] end)
		#IO.inspect finalPerms
		
		IO.inspect bestOfAllHands(finalPerms)
		
	
	end
	
	

	def bestOfAllHands([firstHand, secondHand|tail])do
		#IO.inspect [firstHand, secondHand]++tail

		cond do
			handCompare(firstHand,secondHand) == 1 -> bestOfAllHands([firstHand]++tail)
			handCompare(firstHand,secondHand) == -1 -> bestOfAllHands([secondHand]++tail)
			true -> bestOfAllHands([firstHand]++tail)
		end
	end
	def bestOfAllHands([first]), do: first	
	
	
	
	
	
	
	
	def singleHandList0(_, _, _, _, _, 0), do: []
	
	def singleHandList0(2, numCard, hand, ground, perm, stop)do
		#[firstF,secondF|tailF] = groundFix
	
		#IO.puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		#IO.inspect ground
		#IO.inspect stop
		#IO.inspect numCard
		[first,second|tail] = ground
		perm = perm ++ [tail++hand]
		#IO.inspect perm		
		#IO.puts "^^^^^^^^^^^^^^^^^^^#####^^^^^^^^^^^^^^^^^^^^^^"
		
		
		cond do
			stop == 0 -> perm  
			numCard == 0 -> perm ++ singleHandList0(2, 6, hand, [second]++tail++[first], [], stop-1)
			true -> perm ++ singleHandList0(2, numCard-1, hand, [first]++tail++[second], [], stop)
		end
	end
	
	def singleHandList(1, numCard, firstHnad, ground, perm)do
		[first|tail] = ground	
		perm = perm ++ [tail++firstHnad]
		#IO.inspect perm
		cond do
			numCard == 0 -> perm
			true -> perm ++ singleHandList(1, numCard-1, firstHnad, tail++[first], [])
		end
	end
	def singleHandList(_, _, _, _, _), do: []
	
	
	
	
	
	
	
	
	def cardToString(cardNumber) do
	
		rank = to_string(rem(cardNumber,13))
		rank = 
			cond do
				rank == "0" -> "13"
				true -> rank
			end
			
		cond do
			(cardNumber > 0  && cardNumber < 14) ->
				rank <> "C" 
			(cardNumber > 13  && cardNumber < 27) ->
				rank <> "D" 
			(cardNumber > 26  && cardNumber < 40) ->
				rank <> "H"
			(cardNumber > 39  && cardNumber < 53) ->
				rank <> "S"
			
		end
		
		
	end
	
	
	
	
	def handCompare(hand1,hand2) do
		cond do
			pokerEval(hand1) > pokerEval(hand2) -> 1
			pokerEval(hand1) < pokerEval(hand2) -> -1
			pokerEval(hand1) == pokerEval(hand2) -> pokerTieBreak(hand1, hand2)
			
		end
	end
	
	
	
	
	
	
	def pokerEval(arrayPoker) do
		rankNumber = 0
		suitNumber = 0
		
		dictRank =
			Enum.reduce(arrayPoker, %{}, fn item, dictRank -> 
			itemString = cardToString(item)
			itemStrLen = String.length(itemString)
			itemRank = String.slice(itemString, 0..(itemStrLen-2))
			Map.update(dictRank, itemRank, 1, &(&1 + 1)) 
		end)
		
		recurrence = Map.values(dictRank)
		recurrence = Enum.sort(recurrence)
		#IO.inspect recurrence
		#IO.inspect Map.keys(dictRank)
		
		rankNumber = 
			cond do
				(recurrence == [1,4]) -> 140
				(recurrence == [2,3]) -> 120
				(recurrence == [1,1,3]) -> 60
				(recurrence == [1,2,2]) -> 40
				(recurrence == [1,1,1,2]) ->  20
				(recurrence == [1,1,1,1,1]) -> 1
			end
		
		#rankKeys = Map.keys(dictRank)
		
		#IO.puts rankNumber
		rankKeys = Map.keys(dictRank) |> Enum.map(&String.to_integer/1)
		rankKeys = Enum.sort(rankKeys, :asc)
		[first|_] = rankKeys
		rankNumber =
			cond do 
				(rankKeys == [first,first+1,first+2,first+3,first+4] && rankNumber == 1)-> 80
				(rankKeys == [1,10,11,12,13] && rankNumber == 1)-> 80
				true -> rankNumber
			end
		
		#IO.puts rankNumber
		
		dictSuit =
			Enum.reduce(arrayPoker, %{}, fn itemS, dictSuit -> 
			itemStringS = cardToString(itemS)
			itemStrLenS = String.length(itemStringS)
			itemSuit = String.slice(itemStringS, (itemStrLenS-1)..(itemStrLenS))
			Map.update(dictSuit, itemSuit, 1, &(&1 + 1)) 
		end)
		
		recurrenceS = Map.values(dictSuit)
		recurrenceS = Enum.sort(recurrenceS)
		#IO.inspect recurrenceS
		#IO.inspect Map.keys(dictSuit)
		
		suitNumber = 
			cond do
				(recurrenceS == [5]) -> 100
				true -> 0
			end
		
		
		#IO.puts to_string(rankNumber) <>" + "<> to_string(suitNumber)
		rankNumber+suitNumber
		
	
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	def pokerTieBreak(array1, array2) do
		dictRank1 = arrayToDict(array1)
		dictRank2 = arrayToDict(array2)
		rankKeys1 = Map.keys(dictRank1)
		rankKeys2 = Map.keys(dictRank2)
		arrCompareSort1 =  completeHandSort(rankKeys1,dictRank1)
		arrCompareSort2 =  completeHandSort(rankKeys2,dictRank2)
		#Enum.each(arrCompareSort1, fn item -> IO.puts to_string(item) end)
		#Enum.each(arrCompareSort2, fn item -> IO.puts to_string(item) end)
		
		cond do
			(arrCompareSort1 == [111,5,4,3,2]) -> -1
			(arrCompareSort2 == [111,5,4,3,2]) ->  1
			true -> beat(arrCompareSort1,arrCompareSort2)
		end
		
		
		
	end
	
	
	
	
	
	
	
	def beat([first1|tail1], [first2|tail2]) do
		cond do
			first1 > first2 -> 1
			first2 > first1 -> -1
			first1 == first2 ->  beat(tail1, tail2)
		end
	end
	def beat(_,_), do: 0
	
	
	
	
	
	
	
	def arrayToDict(array1) do
		dictRank =
			Enum.reduce(array1, %{}, fn item, dictRank -> 
			itemString = cardToString(item)
			itemStrLen = String.length(itemString)
			itemRank = String.slice(itemString, 0..(itemStrLen-2))
			itemRank =
				cond do
					(itemRank == "1") -> "111"
					true -> itemRank
				end
			Map.update(dictRank, String.to_integer(itemRank), 1, &(&1 + 1)) 
		end)
	end
	
	
	
	
	
	
	
	
	
	
	def handSort([name1,name2| tail],arr,dict) do
		#IO.puts "a_______"
		#Enum.each(arr, fn item -> IO.puts to_string(item) end)
		#IO.puts "*******"
		x = cond do
				dict[name1] > dict[name2] -> name1
				dict[name1] < dict[name2] -> name2
				(dict[name1] == dict[name2] && name1>name2) -> name1
				true -> name2
			end
		#IO.puts x
		new = arr -- [x]
		#IO.puts "a_____new__"
		#Enum.each(new, fn item -> IO.puts to_string(item) end)
		#IO.puts "a_____new__"
		[x] ++ handSort(new, new, dict)
	end
	def handSort(arr,arr,dict), do: arr
	def handSort(_,_,_), do: [] 
	
	
	
	def completeHandSort(arr,dict) do
		#IO.puts "#########################################################################"
		newArr = handSort(arr,arr,dict)
		cond do
			arr != newArr -> completeHandSort(newArr,dict)
			true -> newArr
		end
	end
	
	
	
	
end