(import scheme)
(import (except (chicken base) define-record-type))
(import (chicken platform))
(import (srfi-99))
(import (chicken module))

(register-feature! 'srfi-136)

(include "srfi/136.scm")
