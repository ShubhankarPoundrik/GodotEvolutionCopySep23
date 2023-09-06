extends Node

var arr:Array = []
var start:int = 0
var end:int = 0
var MAX_LEN = 10000

func _ready():
	for _i in range(MAX_LEN):
		arr.append(null)
		
func push(val):
	if (end+1)%MAX_LEN == start%MAX_LEN:
		return {"success":false}
	arr[end] = val
	end += 1
	end %= MAX_LEN
	return {"success":true}
	
func pop():
	var elem = arr[start]
	if isEmpty():
		return {"success":false}
	start += 1
	start %= MAX_LEN
	return {"success":true, "val":elem}
	
func peek():
	var elem = arr[start]
	if isEmpty():
		return {"success":false}
	return {"success":true, "val":elem}
	
func empty():
	end = start
	
func isEmpty():
	return (arr[start] == null or start == end)
