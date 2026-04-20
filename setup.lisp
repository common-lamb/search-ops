;;;; setup
;; conda create -n env-name
;; conda install bcftools sbcl

;; symlink local asd files
;;   ln -s $(realpath my.system.asd) ~/common-lisp/

;;;; startup
;; M-x conda-env-activate env-name
;; , '
;; nav to project
;; refresh asdf registry
(asdf:initialize-source-registry
 (list :source-registry
       (list :directory (uiop:getcwd))
       (list :tree (uiop:native-namestring "~/common-lisp/"))
       :inherit-configuration))

;; set ocicl to reproducible
  (setf ocicl-runtime:*local-only* t)

;; load
  (asdf:load-system :lamb.genomic.vcf-report)
  (in-package :explore-variants)

;; clone repos if Component :SYSTEM not found in ocicl
;;   git clone https://github.com/user/repo.git ~/common-lisp/repo
