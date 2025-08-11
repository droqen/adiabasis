extends Object
class_name Parcel
var position : Vector2
var velocity : Vector2
var _c : Chunker = null
var _c_chunk : Vector2i
var chunk : Vector2i :
	get() : return _c.pos2chunk(position)

var name : String = "?"
func _to_string(): return name

var heat : float = 100.0
var radius : float :
	get : return heat * 0.3

func register(chunker : Chunker) -> void:
	if self._c != chunker:
		unregister()
		self._c = chunker
		self._c.register(self, self.chunk)
		_c_chunk = self.chunk
		update_chunk()
func unregister() -> void:
	if self._c:
		self._c.unregister(self, _c_chunk)
		self._c = null
func delete() -> void:
	unregister()
	free()
func update_chunk() -> void:
	if self._c and _c_chunk != self.chunk:
		self._c.reregister(self, _c_chunk, self.chunk)
		_c_chunk = self.chunk
