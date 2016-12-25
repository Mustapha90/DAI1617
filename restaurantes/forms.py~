# -*- encoding: utf-8 -*-

from django import forms
from django.core.exceptions import ValidationError
from django.conf import settings
import json
import requests 

conn = settings.CLIENT
db = conn.test 
col = db.restaurants 
modo = ''

class RestForm(forms.Form):
   myClass = forms.TextInput(attrs={'class' : 'input-md  textinput textInput form-control'})
   iden = forms.CharField(widget=myClass,max_length = 100,label="ID")
   nombre = forms.CharField(widget=myClass,max_length = 100,label="Nombre")
   cuisine = forms.CharField(widget=myClass,max_length = 100,label="Cuisine")
   ciudad = forms.CharField(widget=myClass,max_length = 100,label="Ciudad")
   edificio = forms.CharField(widget=myClass,max_length = 100, label="Edificio")
   calle = forms.CharField(widget=myClass,max_length = 100, label="Calle")
   codpostal = forms.CharField(widget=myClass,max_length = 100, label="Código postal")
   latitud = forms.FloatField(widget=myClass,min_value=-90.0, max_value=90.0, label="Latitud")
   longitud = forms.FloatField(widget=myClass,min_value=-180.0, max_value=180.0, label="Longitud")
   restaurante = ''

   def __init__(self, *args, **kwargs):
       global modo
       if 'restaurante' in kwargs:
           restaurante = kwargs.pop('restaurante')
           modo = 'editar'
           super(RestForm, self).__init__(*args, **kwargs)
           self.fields['iden'].initial = restaurante['restaurant_id']
           self.fields['nombre'].initial = restaurante['name']
           self.fields['cuisine'].initial = restaurante['cuisine']
           self.fields['ciudad'].initial = restaurante['borough']
           self.fields['edificio'].initial = restaurante['address']['building']
           self.fields['calle'].initial = restaurante['address']['street']
           self.fields['codpostal'].initial = restaurante['address']['zipcode']
           self.fields['latitud'].initial = restaurante['address']['coord'][0]
           self.fields['longitud'].initial = restaurante['address']['coord'][1]
       else:
           super(RestForm, self).__init__(*args, **kwargs)

   def clean_iden(self):
       global modo
       iden = self.cleaned_data['iden']
       if modo!='editar':
           if col.find_one({'restaurant_id': iden}) != None:
               raise ValidationError("Ya existe un restaurante con el mismo identificador!")
       return iden

   def clean_codpostal(self):
       codpostal = self.cleaned_data['codpostal']
       edificio = self.cleaned_data['edificio']
       ciudad = self.cleaned_data['ciudad']
       calle = self.cleaned_data['calle']
       address = edificio + ',' + calle + ',' + ciudad
       zipcode = get_codpostal(address)
       if zipcode != codpostal:
           raise ValidationError("El código postal no coincide con la dirección!")
       return codpostal



def get_codpostal(address):
    zipcode = -1
    url_request = "https://maps.googleapis.com/maps/api/geocode/json?address=%s&key=%s" % (address, settings.API_KEY)
    result = requests.get(url_request)
    data = result.json()
    if data['status'] != 'ZERO_RESULTS':
        for element in data['results'][0]['address_components']:
            if element['types'][0] == 'postal_code':
                zipcode = element['long_name']

    return zipcode



