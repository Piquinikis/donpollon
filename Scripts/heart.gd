extends Area2D

const HEAL_AMOUNT = 10

@onready var sprite = $Sprite2D

var _time := 0.0
var _base_y: float


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = sprite.position.y


func _process(delta: float) -> void:
	# Pequeño flotecito para que se note que es un ítem agarrable
	_time += delta
	sprite.position.y = _base_y + sin(_time * 3.0) * 2.0


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		body.heal(HEAL_AMOUNT)
		_pickup_effect()


func _pickup_effect() -> void:
	# Evita que se pueda agarrar dos veces mientras desaparece
	set_deferred("monitoring", false)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", scale * 1.4, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(queue_free)
