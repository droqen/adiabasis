extends Node2D

var parcels : Array[Parcel] = []

@onready var simsize = get_viewport().size
@onready var simwidth = simsize.x
@onready var simheight = simsize.y
const NUM_PARTICLES : int = 1000

func _ready() -> void:
	var simarea : float = simwidth * simheight
	var period = sqrt(simarea / NUM_PARTICLES)
	for x in range(0, simwidth - period, period):
		for y in range(0, simheight - period, period):
			var p = Parcel.new()
			p.position = Vector2(x+randf()*period, y+randf()*period)
			p.heat = randf_range(50,150)
			p.register(GLOBAL_CHUNKER)
			parcels.append(p)
func _physics_process(_delta: float) -> void:
	var count : int
	for p in parcels:
		p.update_chunk()
		for p2 in GLOBAL_CHUNKER.getall_3x3(p.chunk):
			if p != p2:
				var to_p2 : Vector2 = p2.position - p.position
				var to_p2_len : float = to_p2.length()
				# receive forces.
				if to_p2_len - p.radius - p2.radius < 10:
					p.velocity -= 10.0 * to_p2 / to_p2_len / to_p2_len
				
		p.velocity.y += 0.1 # pull down (gravity)
		if p.position.x < simwidth/4: p.velocity.x += 0.1
		if p.position.y < simwidth/4: p.velocity.y += 0.1
		if p.position.x > simwidth*3/4: p.velocity.x -= 0.1
		if p.position.y > simheight*3/4: p.velocity.y -= 0.2
		p.velocity *= 0.95
			# push up (ground)
	for p in parcels:
		p.position += p.velocity * 0.5
	queue_redraw()
func _draw() -> void:
	var parcelrect : Rect2 = Rect2(-1,-1,2,2)
	var parcelcol : Color = Color(1,1,1,0.5)
	var parcelcolclear : Color = Color(1,1,1,0.05)
	var parcelbasescale : Vector2 = Vector2.ONE
	#var chunkrect : Rect2 = Rect2(
		#-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		#-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		#GLOBAL_CHUNKER.CHUNK_SIZE,
		#GLOBAL_CHUNKER.CHUNK_SIZE
	#)
	#var chunkcol : Color = Color(1,1,0,0.5)
	for p in parcels:
		#draw_set_transform(GLOBAL_CHUNKER.chunk2pos(p.chunk))
		#draw_rect(chunkrect, chunkcol, false)
		draw_set_transform(p.position)
		draw_rect(parcelrect, parcelcol)
		draw_set_transform(p.position, 0.0, parcelbasescale * p.radius)
		draw_rect(parcelrect, parcelcolclear)
		
