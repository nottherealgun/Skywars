extends Enemy

enum States { IDLE, CHASING, ATTACKING, THROWING }
var state = States.IDLE
var range = 50
var knockback = 1

func _ready():
	super()
	$Sprite.sprite_frames = load("res://enemies/student"+str((randi()%2)+1)+".tres")
	$Sprite.play("idle")
	
func _physics_process(delta):
	super(delta)
	if is_instance_valid(target):
		$Sprite.flip_h = !(target.position.x > position.x)
	match state:
		States.IDLE:
			pass
		States.CHASING:
			_move_update(delta)
			if is_instance_valid(target):
				if position.distance_to(target.get_surround_pos()) <= range:
					change_state(States.ATTACKING)
			else:
				change_state(States.IDLE)
		States.ATTACKING:
			if is_instance_valid(target):
				if position.distance_to(target.position) > range:
					change_state(States.CHASING)
			else:
				change_state(States.IDLE)
			if $Timer.is_stopped():
				target.get_hurt(self)
				$Timer.start()

func affect(victim:Node):
	victim.health -= damage
#	victim.get_knockback(position.direction_to(victim.position),knockback)

func change_state(new_state):
	match new_state:
		States.IDLE:
			$Sprite.play("idle")
		States.CHASING:
			$Sprite.play("run")
		States.ATTACKING:
			$Sprite.play("attack")
		States.THROWING:
			$Sprite.play("throw")
	state = new_state

func _move_update(delta):
	super(delta)
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= range:
#				allies_vec += ((position.direction_to(ally.position))/ally.position.distance_to(position))*10
				var rot : float
				var a = position.direction_to(ally.position).rotated(PI*2/3)*100
				var b = position.direction_to(ally.position).rotated(-PI*2/3)*100
				var c = move_vec.angle_to(position+a)
				var d = move_vec.angle_to(position+b)
#				$a.set_point_position(1,a)
#				$b.set_point_position(1,b)
				if c < d:
					rot = PI*2/3
				else:
					rot = -PI*2/3
				allies_vec = ally.position.direction_to(position).rotated(deg_to_rad(rot))
				
#		position += (move_vec-allies_vec) * speed * delta * 50
	
#		$line.set_point_position(1,(move_vec+allies_vec) *100)
		move_and_collide((move_vec+allies_vec).normalized() * speed * delta * 50)
#		$Dev.text = str((move_vec-allies_vec) * speed * delta * 50)
#		$Dev.text = str(allies_vec*10)

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		change_state(States.CHASING)
