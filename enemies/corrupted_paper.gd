extends Enemy

enum States { IDLE, CHASING, ATTACKING }
var state = States.IDLE
var range = 50
var shoot_speed = 1

func _ready():
	super()
	shoot_speed = level
	$Sprite.sprite_frames = load("res://enemies/corrupted_paper"+str(1+randi()%2)+".tres")

func _physics_process(delta):
	super(delta)
	if is_instance_valid(target):
#		$Dev.text = str(position.distance_to(target.position))
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
			
			if $Sprite.frame == 8:
				target.get_hurt(self)

func affect(victim:Object):
	victim.health-=damage

func change_state(new_state):
	# Check old state
	match state:
		_:
			pass
	# Check new state
	match new_state:
		States.IDLE:
			$Sprite.play("idle")
		States.CHASING:
			$Sprite.play("move")
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
		move_and_collide((move_vec-allies_vec) * speed * delta * 50)

func get_hurt(by:Object):
	super(by)

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		change_state(States.ATTACKING)
