extends Node
class_name Chunker

const CHUNK_SIZE : int = 50
const CHUNK_SIZE_RECIP : float = 1.0 / CHUNK_SIZE
const CHUNK_XMID : int = 0x00008000
const CHUNK_YMID : int = 0x00008000
const CHUNK_XMASK : int = 0xFFFF0000
const CHUNK_XMULT : int = 0x00010000
const CHUNK_YMASK : int = 0x0000FFFF

var chunked_objects : Dictionary[int, Array]

func _reg(o : Object,
prev_chunk_maybe,
new_chunk_maybe) -> void:
	if prev_chunk_maybe:
		var prev_chunk_index : int = chunk2index(prev_chunk_maybe)
		var prev_array : Array = chunked_objects.get(prev_chunk_index,[])
		if !prev_array.is_empty():
			prev_array.erase(o)
			if prev_array.is_empty():
				chunked_objects.erase(prev_chunk_index)
	if new_chunk_maybe:
		var new_chunk_index : int = chunk2index(new_chunk_maybe)
		var new_array : Array = chunked_objects.get(new_chunk_index,[])
		if new_array.is_empty():
			chunked_objects[new_chunk_index] = [o]
		else:
			new_array.append(o)
func register(o : Object, start_chunk : Vector2i) -> void:
	_reg(o, null, start_chunk)
func reregister(o : Object, prev_chunk : Vector2i, new_chunk : Vector2i) -> void:
	_reg(o, prev_chunk, new_chunk)
func unregister(o : Object, prev_chunk : Vector2i) -> void:
	_reg(o, prev_chunk, null)

func pos2index(pos : Vector2) -> int:
	var chunk_x : int = roundi(pos.x * CHUNK_SIZE_RECIP) + CHUNK_XMID
	var chunk_y : int = roundi(pos.y * CHUNK_SIZE_RECIP) + CHUNK_YMID
	return CHUNK_XMASK * chunk_x + chunk_y
func index2pos(chunk : int) -> Vector2:
	var chunk_x : int = (chunk & CHUNK_XMASK) / CHUNK_XMULT
	var chunk_y : int = (chunk & CHUNK_YMASK)
	return Vector2(
		(chunk_x - CHUNK_XMID) * CHUNK_SIZE,
		(chunk_y - CHUNK_YMID) * CHUNK_SIZE
	)
func index2chunk(index : int) -> Vector2i:
	return Vector2i(
		(index & CHUNK_XMASK) / CHUNK_XMULT,
		(index & CHUNK_YMASK)
	)
func chunk2pos(chunk : Vector2i) -> Vector2:
	return Vector2(
		(chunk.x - CHUNK_XMID) * CHUNK_SIZE,
		(chunk.y - CHUNK_YMID) * CHUNK_SIZE
	)
func pos2chunk(pos : Vector2) -> Vector2i:
	return Vector2i(
		roundi(pos.x * CHUNK_SIZE_RECIP) + CHUNK_XMID,
		roundi(pos.y * CHUNK_SIZE_RECIP) + CHUNK_YMID
	)
func chunk2index(chunk : Vector2i) -> int:
	return CHUNK_XMASK * chunk.x + chunk.y

func getall_3x3(chunk : Vector2i) -> Array:
	var index : int = chunk2index(chunk)
	return (
		chunked_objects.get(index, [])
		+ chunked_objects.get(index - 1, [])
		+ chunked_objects.get(index + 1, [])
		+ chunked_objects.get(index - 1 - CHUNK_XMULT, [])
		+ chunked_objects.get(index + 1 - CHUNK_XMULT, [])
		+ chunked_objects.get(index - 1 + CHUNK_XMULT, [])
		+ chunked_objects.get(index + 1 + CHUNK_XMULT, [])
		+ chunked_objects.get(index - CHUNK_XMULT, [])
		+ chunked_objects.get(index + CHUNK_XMULT, [])
	)
