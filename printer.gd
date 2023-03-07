extends Enemy

enum States { IDLE, AWOKEN, ATTACKING }
var state = States.IDLE
var awoken = false
var range = 200
var shoot_speed = 1

func _ready():
	super()
	shoot_speed = level

func _process(delta):
	super(delta)
	$Sprite.flip_h = (move_vec.x > 0)
	match state:
		States.IDLE:
			if is_instance_valid(target):
				if !awoken and position.distance_to(target.position) < range:
					change_state(States.AWOKEN)
					awoken = true
		States.AWOKEN:
			if !$Sprite.is_playing():
				change_state(States.ATTACKING)
		States.ATTACKING:
			if !is_instance_valid(target):
				change_state(States.IDLE)
			if $Timer.is_stopped():
				if $Sprite.frame >= 8:
					var rand_num = randi()%10 # 0 - 9
					var proj_id = 1
					if rand_num == 0:
						proj_id = 0
					
					Global.spawn_projectile(self,["printer_proj_1","printer_proj_2"][proj_id],position,position.direction_to(target.position),false)			
					$Timer.start(1.0/shoot_speed)

func change_state(new_state):
	# Check old state
	match state:
		States.AWOKEN:
			$Healthbar.show()
			$NameTag.show()
	# Check new state
	match new_state:
		States.IDLE:
			$Sprite.play("idle")
		States.AWOKEN:
			$Sprite.play("transform")
		States.ATTACKING:
			$Sprite.play("attack")
	state = new_state

func _move_update(delta):
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= 50:
				allies_vec += (position.direction_to(ally.position)*50)/ally.position.distance_to(position)
		position += (move_vec-allies_vec) * speed * delta * 50

func get_hurt(by:Node):
	if (awoken and state == States.IDLE) or (state == States.ATTACKING):
		super(by)

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if awoken:
			change_state(States.ATTACKING)


