class Device < ApplicationRecord
  belongs_to :product
  has_many :device_sim_histories, dependent: :destroy
  has_many :assignments

  enum :status, {
    available: 0, #en almacen listo para salir
    assigned: 1, #asignado a una sim
    installed: 2, # en un vehiculo de cliente "vendido"
    in_warranty: 3, #ingresado a laboratorio
    damaged: 4, #Dado de baja por daño irreparable
    returned: 5 #garantía interna(devuelta a proveedor)
  }

  validates :imei, presence: true, uniqueness: true
end