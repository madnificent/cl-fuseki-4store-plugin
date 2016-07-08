(in-package :4store-fuseki)

(defclass 4store-server (cl-fuseki::server)
  ()
  (:documentation "endpoint used for making 4store calls."))

(defclass 4store-repository (cl-fuseki::virtuoso-repository)
  ()
  (:documentation "repository for 4store endpoints."))

(defmethod cl-fuseki::server-query-endpoint-postfix ((server 4store-server))
	"/sparql/")
(defmethod cl-fuseki::server-update-endpoint-postfix ((server 4store-server))
	"/update/")
(defmethod cl-fuseki::server-data-endpoint-postfix ((server 4store-server))
	"/sparql/")
(defmethod cl-fuseki::server-upload-endpoint-postfix ((server 4store-server))
	"/update/")

(defmethod cl-fuseki::query-raw ((repos 4store-repository) (query string) &rest options &key &allow-other-keys)
  (cl-fuseki::flush-updates repos)
  (let ((full-query (apply #'cl-fuseki::query-update-prefixes query options)))
    (cl-fuseki::maybe-log-query full-query)
    (sparql-query repos full-query)))

(defmethod cl-fuseki::update-now ((repos 4store-repository) (update string))
  (sparql-update repos update))

(defun sparql-query (repos full-query)
	(cl-fuseki::send-request (cl-fuseki::query-endpoint repos)
													 :accept "text/html"
													 :method :post
													 :content-type "application/x-www-form-urlencoded"
													 :parameters `(("query" . ,full-query)
																				 ("output" . "json")
																				 ("soft-limit" . ""))))

(defun sparql-update (repos update-query)
	(cl-fuseki::send-request (cl-fuseki::update-endpoint repos)
													 :accept (cl-fuseki::get-data-type-binding :json)
													 :method :post
													 :parameters `(("update" . ,update-query))))


(defmethod fuseki::query ((repos 4store-repository) (query string) &rest options &key &allow-other-keys)
	(let* ((response (apply #'cl-fuseki::query-raw repos query options))
				 (result (jsown:filter (jsown:parse response)
															 "results" "bindings")))
		;; remove blank objects, they're expected not to be returned
		(loop for object in result
			 collect
				 (loop for k-v in object
						unless (and (listp k-v)
									(eq (second k-v) :obj)
									(= (length k-v) 2))
						collect k-v))))
