require 'pagy'
require 'pagy/extras/arel'
require 'pagy/extras/countless'
require "pagy/extras/overflow"
require 'pagy/extras/i18n'  # internacionalización

Pagy::DEFAULT[:items] = 10     # default visible
#Pagy::DEFAULT[:size]  = [1,4,4,1] # tamaño de la nav bar
