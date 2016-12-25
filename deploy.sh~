#!/bin/bash          

heroku apps:create --region eu
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set ON_HEROKU=1
heroku config:set SECRET_KEY=`openssl rand -base64 32`
heroku config:set MONGO_URI=$1
heroku config:set API_KEY=$2
git push heroku master
heroku run python manage.py migrate --noinput
heroku open
