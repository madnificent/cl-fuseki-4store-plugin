(defpackage 4store-fuseki
  (:use :cl :cl-fuseki)
	(:shadowing-import-from :cl-fuseki :delete)
  (:export :4store-server :4store-repository))
