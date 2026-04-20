(defsystem :lamb.files.search
  :depends-on (
               ;; essential
               :cmd
               :alexandria
               :access
               :arrow-macros
               :serapeum
               :iterate
               :str
               :bordeaux-threads

               ;; this project
               :filesystem-utils
               :file-finder

               ;; clone
               :lisp-xl ; defunkydrummer/lisp-xl
               :filepaths
               )
  :serial t
  :components ((:file "find-files"))
  )
