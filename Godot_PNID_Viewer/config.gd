extends Node

# 


# Static visual
const SYMBOL_COLOR_PRESET = [Color.RED, Color.GREEN, Color.BLUE, Color.MAGENTA, Color.CYAN, Color.ORANGE]
const DEFAULT_LINE_WIDTH = 3.0
const SHOW_ROTATION_LINE = true

# Symbol editing visuals
const EDITOR_RECT_COLOR: Color = Color.CORAL
const EDITOR_RECT_LINE_WIDTH: float = 5
const EDITOR_ROTATION_HANDLE_OFFSET: float = 40
const EDITOR_HANDLE_SIZE = 20
const EDITOR_HANDLE_COLOR: Color = Color.BLUE_VIOLET
const EDITOR_MINIMUM_SYMBOL_SIZE: int = 5
const EDITOR_HANDLE_PADDING: float = 10

# XML
const OBJECT_TAG_NAME = "symbol_object"
const FORCE_QUANTIZED_DEGREE = true
const QUANTIZED_DEGREE_VALUE = 5
const FORCE_INT_COORD = true # only applied when exporting xml (use float internally)
const TEXT_TYPE_NAME = "text"

# Interaction
const CONTEXT_MENU_THRESHOLD = 10
const CAMERA_ZOOM_TICK = 0.05
