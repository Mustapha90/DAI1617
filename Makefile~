# Instalar dependencias
install:
	pip install -r requirements.txt

#Crear la base de datos
migrate:
	python manage.py makemigrations --noinput
	python manage.py migrate --noinput

# Lanzar la aplicación
run:
	python manage.py runserver 0.0.0.0:5000

