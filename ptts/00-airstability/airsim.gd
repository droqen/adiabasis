extends Node2D

var parcels : Array[Parcel] = []

const ADIABATIC_LAPSE_RATE : float = 0.00015

@onready var simsize = get_viewport().size
@onready var simwidth = simsize.x
@onready var simheight = simsize.y
const NUM_PARTICLES : int = 1000

var forces : Array

func _ready() -> void:
	var simarea : float = simwidth * simheight
	var period = sqrt(simarea / NUM_PARTICLES)
	for x in range(0, simwidth - period, period):
		for y in range(0, simheight - period, period):
			var p = Parcel.new()
			p.position = Vector2(x+randf()*period, y+randf()*period)
			p.heat = 0.5 + 0.5*randf()
			#if x < simwidth/2:
				#p.heat = 0.5 + p.position.y * ADIABATIC_LAPSE_RATE
			#else:
				#p.heat = 0.9 + p.position.y * ADIABATIC_LAPSE_RATE
			p.register(GLOBAL_CHUNKER)
			parcels.append(p)
func _physics_process(_delta: float) -> void:
	forces = []
	var count : int
	for p in parcels:
		p.update_chunk()
		for p2 in GLOBAL_CHUNKER.getall_3x3(p.chunk):
			if p != p2:
				var to_p2 : Vector2 = p2.position - p.position
				var to_p2_len : float = to_p2.length()
				var to_p2_overlap : float = p.radius + p2.radius - to_p2_len
				# receive forces.
				if to_p2_overlap > 0:
					p.velocity -= 0.002 * to_p2 / to_p2_len * to_p2_overlap * to_p2_overlap
					#forces.append([p.position,p2.position])
				
		p.velocity.y += 0.1 # pull down (gravity)
		if p.position.x < simwidth*0.10:
			if p.velocity.x < 0: p.velocity.x *= 0.5
			p.velocity.x += 0.1
		if p.position.y < simheight*0.10: p.velocity.y += 0.1
		if p.position.x > simwidth*0.90:
			if p.velocity.x > 0: p.velocity.x *= 0.5
			p.velocity.x -= 0.1
		if p.position.y > simheight*0.90:
			if p.velocity.y > 0: p.velocity.y *= 0.5
			p.velocity.y -= 0.1
			# push up (ground)
	for p in parcels:
		var move = p.velocity * 0.5
		p.position += move
		p.heat += move.y * ADIABATIC_LAPSE_RATE # adiabatic temp change
			# lower = hotter
		
	queue_redraw()
func _draw() -> void:
	#draw_rect(Rect2(simwidth/4,simheight/4,simwidth/2,simheight/2), Color.YELLOW, false)
	var parcelrect : Rect2 = Rect2(-3,-3,6,6)
	var parcelcol : Color = Color(1,1,1,0.5)
	var parcelcolclear : Color = Color(1,1,1,0.04)
	var parcelbasescale : Vector2 = Vector2.ONE
	var chunkrect : Rect2 = Rect2(
		-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		-GLOBAL_CHUNKER.CHUNK_SIZE/2,
		GLOBAL_CHUNKER.CHUNK_SIZE,
		GLOBAL_CHUNKER.CHUNK_SIZE
	)
	var chunkcol : Color = Color(.3,.7,.7,0.1)
	var coldtempval : float = 0.5
	var warmtempval : float = 1.1
	var coldcol : Color = Color.AQUA
	var middcol : Color = Color.SEA_GREEN
	var warmcol : Color = Color.ORANGE
	for p in parcels:
		#draw_set_transform(GLOBAL_CHUNKER.chunk2pos(p.chunk))
		#draw_rect(chunkrect, chunkcol)
		#draw_rect(chunkrect, chunkcol, false)
		var col = lerp(coldcol,warmcol,inverse_lerp(0.5, 1.0, p.heat))
		draw_set_transform(p.position)
		draw_rect(parcelrect, col)
		#draw_set_transform(p.position, 0.0, parcelbasescale * p.radius * .5)
		#draw_rect(parcelrect, parcelcolclear)
	draw_set_transform(Vector2.ZERO)
	#for f in forces:
		#draw_line(f[0],f[1],Color.YELLOW)
