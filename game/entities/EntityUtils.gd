class_name EntityUtils
extends Object


static func size_to_px(size: int) -> float:
	return size * GameSettings.CELL_SIZE * 4

static func size_to_boundary_px(size: int) -> float:
	return size_to_px(size) + GameSettings.TOOTH_HEIGHT / 4

static func size_to_collider_px(size: int) -> float:
	return size_to_px(size) + GameSettings.TOOTH_HEIGHT / 8
