# DAI1617



##Despliegue de la aplicación

El despliegue se ha realizado en el PaaS Heroku a continuación se explicarán los pasos seguidos.


##Preparación de la aplicación para el despliegue

###Configuración de las bases de datos

Se han usado dos bases de datos, una para el registro de usuarios (Postgres de Heroku) y otra para los datos de restaurantes (MongoDB).

####Configuración de las base de datos de restaurantes

Creamos una base de datos remota en [mLab](https://mlab.com/) que es una plataforma de base de datos como servicio (DBaaS), para alojar y gestionar bases de datos MongoDB.

Para poder conectarse a la base de datos hay que crear un usuario, esto se puede hacer desde nuestra cuenta en mLab.

Ahora importamos los datos de restaurantes a la base de datos remota, como hicimos en la práctica 4:

``$ mongoimport -h <host>.mlab.com:<puerto> -d restaurantes -c restaurantes -u <dbuser> -p <dbpass> --file primer-dataset.json.txt``

Ya podemos trabajar con la base de datos.

####Configuración del contenido estático

Hay que añadir la configuración correcta para que nuestra aplicación podrá servir contenido estático en el PaaS.

Para lograrlo usaremos ``whitenoise``, editamos el fichero ``wsgi.py`` de nuestra aplicación

```python
import os

from django.core.wsgi import get_wsgi_application
from whitenoise.django import DjangoWhiteNoise

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "practica7.settings")

application = get_wsgi_application()
application = DjangoWhiteNoise(application)

```

Añadimos la siguiente linea en el fichero de configuración ``settings.py``

```python
STATICFILES_STORAGE = 'whitenoise.django.GzipManifestStaticFilesStorage'
```

####Configuración de las variables de entorno

Para configurar las variables de entorno en el PaaS usaremos los paquetes python-decouple y dj-database-url.

Editamos el fichero de configuración ``settings.py``:

```python
import os
from pymongo import MongoClient
from decouple import config
import dj_database_url


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))

# Variable que indica que el entorno es Heroku
ON_HEROKU = 'ON_HEROKU' in os.environ

# Configuración para Heroku
if ON_HEROKU:  

    # Conectarse a la base de datos remota usando la variable de entorno MONGO_URI
    CLIENT = MongoClient(config('MONGO_URI'))
    DB = CLIENT.restaurantes

    # Obtener la clave secreta desde la variable de entorno SECRET_KEY
    SECRET_KEY = config('SECRET_KEY')

    # Deshabilitar la depuración
    DEBUG = config('DEBUG', default=False, cast=bool)

    # Configuración de la base de datos Postgres
    DATABASES = {
          'default': dj_database_url.config(
          default=config('DATABASE_URL')
          )
    }

    # Permitir el acceso externo
    ALLOWED_HOSTS = ['*']

    #Obtener la varaible de entorno que contiene la clave de la api de google
    API_KEY = config('API_KEY')

# Configuración normal
else:
    # Usamos la base de datos local de mongo
    CLIENT = MongoClient()
    DB = CLIENT.test

    # Clave secreta
    SECRET_KEY = 'xxxxxxxx'

    # No permitir el acceso externo
    ALLOWED_HOSTS = []

    # Habilitar la depuración
    DEBUG = True

    # Usar la base de datos sqlite3
    DATABASES = {
        'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
         }
    }
    
    # Clave de la api de google
    API_KEY='xxxxxxxxxxxx'

...
...
...
```

##Ficheros de configuración del PaaS

Para desplegar la aplicación necesitamos los siguientes ficheros de configuración:

``requirements.txt``

Contiene las dependencias necesarias para el despliegue en el PaaS

```
pymongo==3.4.0
Django==1.10.4
django-registration-redux==1.4
whitenoise
dj-database-url==0.3.0
python-decouple==3
dj-static==0.0.6
gunicorn==19.6.0
psycopg2==2.6.1
requests==2.12.4
django-widget-tweaks==1.4.1
```

**``runtime.txt``**

Contiene la versión de python necesaria para ejecutar la aplicación

```
python-2.7.12
```

**``Procfile``**

Contiene la orden que se usará para ejecutar la aplicación

```
web: gunicorn tango_with_django_project.wsgi --log-file -
```

##Despliegue en Heroku

Ya tenemos la configuración necesaria para desplegar la aplicación en heroku.

-Creamos una aplicación en Heroku especificando la región y el nombre

``$ heroku apps:create dai1617 --region eu``

-Creamos la base de datos Postgres

``$ heroku addons:create heroku-postgresql:hobby-dev``

-Creamos las variables de entorno

``$ heroku config:set ON_HEROKU=1``

``$ heroku config:set SECRET_KEY=`openssl rand -base64 32` ``

``$ heroku config:set API_KEY=-----------``

``$ heroku config:set MONGO_URI=mongodb://dbuser:<dbuser>@<host>.mlab.com:<puerto>/<dbname>``

-Iniciamos el despliegue de la aplicación

``$ git push heroku master``

-Creamos las tablas de la base de datos

``$ heroku run python manage.py migrate --noinput``

-Visualizamos la aplicación en el navegador:

``$ heroku open``

La aplicación se encuentra desplegada en el siguiente enlace:

[heroku](https://dai1617.herokuapp.com/)







