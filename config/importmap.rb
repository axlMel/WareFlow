# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "tailwindcss-stimulus-components" # @6.1.3
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin_all_from "app/javascript/channels", under: "channels"
