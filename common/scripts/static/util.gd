class_name Util
extends Node


static func instantiate(obj: PackedScene, point: Vector3, direction: Vector3 = Vector3.ZERO, scale: float = 1.0, parent = null) -> Node:
	var new_obj = obj.instantiate()
	if parent != null:
		parent.add_child(new_obj)
		var fix_scale = parent.global_transform.basis.get_scale()
		new_obj.set_scale(Vector3(1/fix_scale.x, 1/fix_scale.y, 1/fix_scale.z))
	else:
		Global.stage_root.add_child(new_obj)
	new_obj.global_transform = Transform3D(Basis.IDENTITY, point)
	if direction != Vector3.ZERO:
		fixed_look_at(new_obj, point + direction)
	new_obj.global_scale(Vector3.ONE * scale)
	return new_obj


static func delta_lerp(from: Variant, to: Variant, speed: float, delta: float) -> Variant:
	return lerp(from, to, 1.0 - exp(-speed * delta))


static func map(x, in_min, in_max, out_min, out_max):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


static func short_angle_dist(from, to) -> float:
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference


static func constant_speed_yaw(object: Node3D, point_to_face: Vector3, rot_speed: float, delta: float):
	var direction = point_to_face.direction_to(object.global_position)
	var front = object.global_transform.basis.z
	var ang = Vector2(front.x, front.z).angle_to(Vector2(direction.x, direction.z))
	var s = sign(ang)
	if abs(rad_to_deg(ang)) <= 179.99:
		object.rotate_y(clamp(180 - abs(rad_to_deg(ang)), 0.01, rot_speed) * delta * s)


static func fixed_look_at(obj: Node3D, lookat: Vector3):
	var dir_between = obj.global_position.direction_to(lookat)
	if dir_between.is_equal_approx(Vector3.UP):
		obj.rotation_degrees.x = 90
	elif dir_between.is_equal_approx(Vector3.DOWN):
		obj.rotation_degrees.x = -90
	elif not obj.global_position.is_equal_approx(lookat):
		obj.look_at(lookat, Vector3.UP)


static func fixed_looking_at(trans: Transform3D, lookat: Vector3) -> Transform3D:
	var new_trans = Transform3D(trans)
	var dir_between = new_trans.origin.direction_to(lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not new_trans.origin.is_equal_approx(lookat):
				new_trans = new_trans.looking_at(lookat, Vector3.UP)
	return new_trans


static func fixed_look_at_y(obj: Node3D, lookat: Vector3):
	# 0 out the y coord to only look on one axis
	var test_trans = Transform3D(obj.global_transform.basis, Vector3(obj.global_position.x, 0.0, obj.global_position.z))
	var test_lookat = Vector3(lookat.x, 0.0, lookat.z)
	var dir_between = get_flat_direction(obj.global_position, test_lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not test_trans.origin.is_equal_approx(test_lookat):
				test_trans = test_trans.looking_at(test_lookat, Vector3.UP)
	obj.global_transform.basis = test_trans.basis


static func fixed_looking_at_y(trans: Transform3D, lookat: Vector3) -> Transform3D:
	# 0 out the y coord to only look on one axis
	var test_trans = Transform3D(trans.basis, Vector3(trans.origin.x, 0.0, trans.origin.z))
	var test_lookat = Vector3(lookat.x, 0.0, lookat.z)
	var dir_between = test_trans.origin.direction_to(test_lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not test_trans.origin.is_equal_approx(test_lookat):
				test_trans = test_trans.looking_at(test_lookat, Vector3.UP)
	return test_trans


static func get_flat_direction(start: Vector3, dest: Vector3) -> Vector3:
	var self_no_y = Vector3(start.x, 0.0, start.z)
	var point_no_y = Vector3(dest.x, 0.0, dest.z)
	return self_no_y.direction_to(point_no_y)


static func get_flat_distance(start: Vector3, dest: Vector3) -> float:
	var self_no_y = Vector3(start.x, 0.0, start.z)
	var point_no_y = Vector3(dest.x, 0.0, dest.z)
	return self_no_y.distance_to(point_no_y)


# Return an array of all files in <path> that contain substring <filter>
# TODO In 4.4 the load_directory() func will be here and can get rid of the .remap replace stuff
static func load_all_in_path(path: String, filter: String = "", recursive: bool = false) -> Array:
	var files_found = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		file_name = file_name.replace(".remap", "")
		while file_name != "":
			if not dir.current_is_dir():
				if filter == "" or file_name.find(filter) != -1:
					files_found.append(path + file_name)
			elif recursive:
				files_found += load_all_in_path(path + file_name + "/", filter, recursive)
			file_name = dir.get_next()
			file_name = file_name.replace(".remap", "")
	else:
		push_error("Tried to load a file instead of dir")
	return files_found


static func center_window():
	var half_screen_size = DisplayServer.screen_get_size() * 0.5
	var half_window_size = DisplayServer.window_get_size() * 0.5
	if not Engine.is_embedded_in_editor():
		DisplayServer.window_set_position(half_screen_size - half_window_size)


static func quit_to_menu(tree: SceneTree):
	tree.change_scene_to_packed(load("res://interface/main_menu/main_menu.tscn"))
	tree.paused = false


## You can call this in the _ready on any node where _process might throw errors before things are ready
static func await_stage_ready(node: Node, ready_process_mode: int = Node.PROCESS_MODE_INHERIT):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	Events.stage_ready.connect(node.set.bind("process_mode",  ready_process_mode))
