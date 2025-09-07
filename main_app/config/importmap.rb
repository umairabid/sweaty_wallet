# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/channels', under: 'channels'
pin_all_from 'app/javascript/lib', under: 'lib'
pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'flowbite', to: 'https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.turbo.min.js'
pin 'dropzone' # @6.0.0
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin 'just-extend' # @5.1.1
pin 'd3', to: 'https://cdn.jsdelivr.net/npm/d3@7/+esm'
pin 'tom-select', to: 'https://cdn.jsdelivr.net/npm/tom-select@2.4.3/dist/js/tom-select.complete.min.js'
pin 'lodash' # @4.17.21
pin "echarts", to: "echarts.min.js"
pin "echarts/theme/dark", to: "echarts/theme/dark.js"
pin "echarts.themeloader", to: "echarts.themeloader.js"
