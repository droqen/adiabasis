extends Node2D

var parcels : Array[Parcel] = []

func _ready() -> void:
	for i in range(1000):
		var p = Parcel.new()
		p.name = "#%d"%i
		p.position = Vector2(randf()*500.4,randf()*321.0)
		p.register(GLOBAL_CHUNKER)
		parcels.append(p)
func _physics_process(_delta: float) -> void:
	var count : int
	for p in parcels:
		p.position *= 1.001
		p.update_chunk()
		count += len(GLOBAL_CHUNKER.getall_3x3(p.chunk))
		#print("neighbours of parcel %s at %s : %s" % [
			#str(p),
			#str(p.chunk),
			#str(GLOBAL_CHUNKER.getall_3x3(p.chunk))
		#])
	print("each p has average of %f neighbours" % [count*1.0/len(parcels)])
	queue_redraw()
func _draw() -> void:
	var parcelrect : Rect2 = Rect2(-1,1,2,2)
	var parcelcol : Color = Color(1,1,1,0.5)
	var chunkrect : Rect2 = Rect2(
		-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		GLOBAL_CHUNKER.CHUNK_SIZE,
		GLOBAL_CHUNKER.CHUNK_SIZE
	)
	var chunkcol : Color = Color(1,1,0,0.5)
	for p in parcels:
		draw_set_transform(GLOBAL_CHUNKER.chunk2pos(p.chunk))
		draw_rect(chunkrect, chunkcol, false)
		draw_set_transform(p.position)
		draw_rect(parcelrect, parcelcol)
		
