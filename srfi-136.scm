(import scheme)
(import (except (chicken base) define-record-type))
(import (chicken platform))
(import (srfi-99))

(register-feature! 'srfi-136)

(include "srfi/136.scm")
