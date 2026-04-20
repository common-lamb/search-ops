(defpackage #:search
  (:use :cl)
  (:local-nicknames (:i :iterate)
                    (:a :alexandria)
                    (:s :serapeum)
                    (:u :uiop)
                    (:bt :bordeaux-threads-2)
                    (:fifi :file-finder)
                    (:xlsx :lisp-xl))
  (:export
   :*files-root*
   :*found-xlsx*
   :*thread-search-xlsx*
   :f-p
   :search-extension
   :compute-xlsx
   :collect-xlsx
   :filter-name
   :filter-path
   :childpathp
   ))

(in-package #:search)

;; example named multi thread

;; fun with args
(defun yap-sleep-yap (seconds)
  (format t "begin ~A~%" seconds)
  (sleep seconds)
  (format t "end ~A~%" seconds)
  seconds)

;; fun with no args around arg call
(defun yap-sleep-yap-call ()
  (let ((seconds 5))
    (yap-sleep-yap seconds)))

;; do thread on no arg
(bt:make-thread
 'yap-sleep-yap-call
 :name "ysy-call")

;; see named thread when executing
(bt:all-threads)

;; capture thread
(defparameter *test*
  (bt:make-thread
   'yap-sleep-yap-call
   :name "ysy-call"))

;; extract returned value, &&& blocks?
(bt:join-thread *test*)

;;;; functions

(defun search-extension (search-root extension)
  "recursive search for files ending with \"extension\"
args
  *search-root* #P
  extension string of filetype eg \"xlsx\" "
  ;; assert root E
  (assert (not (null (probe-file search-root)))
          (search-root)
          "Root of the search must exist. entered: ~A" search-root)
  (handler-bind (
                 ;; &&& catch [Condition of type SB-KERNEL:NAMESTRING-PARSE-ERROR]
                 (error (lambda (c)
                          (format t "we do not yet handle this condition: ~a" c))))
    (fifi:finder* :root (fifi:file search-root)
                  :predicates (list (fifi:extension= extension)
                                    ;; drop any temp files
                                    ;; windows lock file prefix
                                    (complement (fifi:name~ "~$"))))))

(defun f-p (f)
  "convert a #F path to #P path"
  (probe-file (fifi:path f)))

;;;; searches

(defparameter *files-root* nil
  "default root for precomputed results")

;; precompute xlsx search
(defparameter *found-xlsx* nil
  "to hold the results of collect-X")
(defparameter *thread-search-xlsx* nil
  "to hold thread for compute-X")

(defun search-xlsx ()
  "simple no arg search"
  (search-extension *files-root* "xlsx"))

(defun compute-xlsx ()
  "initiate async search
uses the *thread-search-X* parameter"
  (setf *thread-search-xlsx* (bt:make-thread 'search-xlsx
                                             :name "search-xlsx")))

(defun collect-xlsx ()
  "concludes search
&&& use (bt:all-threads) first!
joins the thread set by compute-X
sets the variable *found-X*
"
  (setf *found-xlsx* (bt:join-thread *thread-search-xlsx*)))

;; &&& precompute vcf search

;; search, list of fields:lines/sites/entries/
;; sort options
;; path, hits:all/term-1/.../term-n
;; options
;; sub-search, path-contains

(defun filter-name (paths str &key (keep t keep-suppliedp) (drop nil drop-suppliedp))
  "filters pathname-name by string"
  ;; both nil
  (assert (not (and (null keep)
                    (null drop)))
          () "one of keep/drop must be t")
  ;; both t and both supplied
  (assert (not (and (and keep drop)
                    (and keep-suppliedp drop-suppliedp)))
          () "only one of keep/drop can be t")
  ;; known: 1 true and supplied
  (when keep
    (remove str paths :key #'pathname-name :test-not #'str:containsp))
  (when drop
    (remove str paths :key #'pathname-name :test #'str:containsp)))

;; filter by directory
(defun childpathp (base-pathname maybe-childpath)
  (uiop:subpathp maybe-childpath base-pathname))

(defun filter-path (paths path &key (keep t keep-suppliedp) (drop nil drop-suppliedp))
  "filters pathname-name by string"
  ;; both nil
  (assert (not (and (null keep)
                    (null drop)))
          ()
          "one of keep/drop must be t")
  ;; both t and both supplied
  (assert (not (and (and keep drop)
                    (and keep-suppliedp drop-suppliedp)))
          ()
          "only one of keep/drop can be t")
  (when keep
    (remove path paths :test-not #'childpathp))
  (when drop
    (remove path paths :test #'childpathp)))
