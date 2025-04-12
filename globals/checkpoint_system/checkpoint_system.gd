extends Node

var last_checkpoint_position: Vector3 = Vector3.ZERO

var collectible_count: int = 0:
	set(value):
		collectible_count = value
		print("test")
		SignalBus.collectible_count_changed.emit()
var collectible_max: int
var collectibles: Array[Collectible]

# True if collectible has been collected.
# String-Typed instead of Collectible-Typed because of weird errors.
var collectibles_status: Dictionary[String, bool] = {}


# Initializes the collectible tracking system. Must be called by the Level scene.
func init_system(collectibles_parent: Node) -> void:
	for child: Collectible in collectibles_parent.get_children():
		collectibles.append(child)
	for collectible in collectibles:
		collectibles_status[collectible.name] = false
	collectible_max = collectibles.size()
	SignalBus.collectible_count_changed.emit()


# Called when a checkpoint is collected.
func checkpoint_collected(checkpoint: Checkpoint) -> void:
	# Update location for respawning.
	last_checkpoint_position = checkpoint.global_position

	# Update the status of collectibles.
	for collectible in collectibles:
		collectibles_status[collectible.name] = collectible.collected_flag


# Resets collectibles to their previous snapshot. Called when the Player dies.
func reset_collectibles() -> void:
	for collectible in collectibles:
		if collectibles_status[collectible.name] == false:
			collectible.un_collect()
