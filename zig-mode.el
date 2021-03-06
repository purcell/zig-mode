;;; zig-mode.el --- A major mode for the Zig programming language -*- lexical-binding: t -*-

;; Version: 0.0.2
;; Author: Andrea Orru <andreaorru1991@gmail.com>, Andrew Kelley <superjoe30@gmail.com>
;; Keywords: zig, languages
;; Package-Requires: ((emacs "24.0"))
;; URL: https://github.com/AndreaOrru/zig-mode

;;; Commentary:
;;

;;; Code:

(require 'cc-mode)

(defun zig-re-word (inner)
  "Construct a regular expression for the word INNER."
  (concat "\\<" inner "\\>"))

(defun zig-re-grab (inner)
  "Construct a group regular expression for INNER."
  (concat "\\(" inner "\\)"))

(defconst zig-re-identifier "[[:word:]_][[:word:]_[:digit:]]*")
(defconst zig-re-type-annotation
  (concat (zig-re-grab zig-re-identifier)
          "[[:space:]]*:[[:space:]]*"
          (zig-re-grab zig-re-identifier)))

(defun zig-re-definition (dtype)
  "Construct a regular expression for definitions of type DTYPE."
  (concat (zig-re-word dtype) "[[:space:]]+" (zig-re-grab zig-re-identifier)))

(defconst zig-syntax-table
  (let ((table (make-syntax-table)))

    ;; Operators
    (dolist (i '(?+ ?- ?* ?/ ?% ?& ?| ?= ?! ?< ?>))
      (modify-syntax-entry i "." table))

    ;; Strings
    (modify-syntax-entry ?\' "\"" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)

    ;; Comments
    (modify-syntax-entry ?/  ". 12" table)
    (modify-syntax-entry ?\n ">"    table)

    table))

(defconst zig-keywords
  '("const" "var"
    "export" "extern" "pub"

    "noalias"
    "inline" "comptime"
    "nakedcc" "coldcc"
    "volatile"

    "packed" "struct" "enum" "union"
    "fn" "use" "test"

    "asm" "goto" "try"
    "break" "return" "continue" "defer"
    "unreachable"

    "if" "else" "switch"
    "and" "or"

    "while" "for"))

(defconst zig-types
  '("void" "noreturn" "type" "error"

    "i8" "i16" "i32" "i64" "isize"
    "u8" "u16" "u32" "u64" "usize"
    "f32" "f64"
    "bool"

    "c_short"  "c_int"  "c_long"  "c_longlong"
    "c_ushort" "c_uint" "c_ulong" "c_ulonglong"
    "c_long_double"))

(defconst zig-constants
  '("null" "undefined" "this"
    "true" "false"))

(defvar zig-font-lock-keywords
  (append
   `(
     ;; Builtins (prefixed with @)
     (,(concat "@" zig-re-identifier) . font-lock-builtin-face)

     ;; Keywords, constants and types
     (,(regexp-opt zig-keywords  'symbols) . font-lock-keyword-face)
     (,(regexp-opt zig-constants 'symbols) . font-lock-constant-face)
     (,(regexp-opt zig-types     'symbols) . font-lock-type-face)

     ;; Type annotations (both variable and type)
     (,zig-re-type-annotation 1 font-lock-variable-name-face)
     (,zig-re-type-annotation 2 font-lock-type-face)
     )

   ;; Definitions
   (mapcar #'(lambda (x)
               (list (zig-re-definition (car x))
                     1 (cdr x)))
           '(("const" . font-lock-variable-name-face)
             ("var"   . font-lock-variable-name-face)
             ("fn"    . font-lock-function-name-face)))))

;;;###autoload
(define-derived-mode zig-mode c-mode "Zig"
  "A major mode for the zig programming language."
  :syntax-table zig-syntax-table
  (setq c-basic-offset 4)
  (setq font-lock-defaults '(zig-font-lock-keywords)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.zig\\'" . zig-mode))

(provide 'zig-mode)
;;; zig-mode.el ends here
