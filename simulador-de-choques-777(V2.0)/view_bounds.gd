class_name ViewBounds
extends Node
## ÚNICA responsabilidad: informar qué zona del MUNDO se ve en pantalla.
## Usa la transformación del canvas del viewport, así que funciona con cualquier
## cámara (zoom, desplazamiento) sin conocer ningún nodo Camera2D.
## Heredar y sobrescribir `rect_visible()` permite otras fuentes (por ejemplo, en pruebas).

func rect_visible() -> Rect2:
	var vista: Viewport = get_viewport()
	return vista.get_canvas_transform().affine_inverse() * vista.get_visible_rect()
