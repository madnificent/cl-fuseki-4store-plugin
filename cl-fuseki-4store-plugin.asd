(asdf:defsystem :cl-fuseki-4store-plugin
  :name "cl-fuseki-4store-plugin"
  :author "Aad Versteden <madnificent@gmail.com>"
  :version "0.0.1"
  :maintainer "Aad Versteden <madnificent@gmail.com>"
  :licence "MIT"
  :description "Plugin for cl-fuseki to run on 4store."
  :serial t
  :depends-on (:cl-fuseki :drakma)
  :components ((:file "packages")
               (:file "4store-fuseki")))
