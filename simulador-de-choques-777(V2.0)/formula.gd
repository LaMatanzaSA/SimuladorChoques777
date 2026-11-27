extends Label

var velocidad_mostrar: int = 0:
	set(valor):
		velocidad_mostrar = valor
		# Como el script ya está dentro del Label, modificas 'text' directamente
		text = "Puntos: %d" % velocidad_mostrar
