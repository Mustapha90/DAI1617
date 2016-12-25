migrate:
	python manage.py migrate


# Instalar dependencias
install:
	pip install -r requirements.txt

#Crear la base de datos
migrate:
	python manage.py makemigrations --noinput
	python manage.py migrate --noinput


# Desplegar la aplicación en Heroku
deploy:
	heroku apps:create --region eu
	heroku addons:create heroku-postgresql:hobby-dev
	heroku config:set ON_HEROKU=1
	heroku config:set SECRET_KEY=`openssl rand -base64 32`
	heroku config:set API_KEY=
	git push heroku master
	heroku run python manage.py migrate --noinput
	heroku run python populate_db.py
	heroku open

# Lanzar la aplicación
run:
	python manage.py runserver 0.0.0.0:5000

