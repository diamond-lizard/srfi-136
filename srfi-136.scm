(import scheme)
(import (except (chicken base) define-record-type))
(import (chicken platform))
(import (srfi-99))
(import r7rs)

(register-feature! 'srfi-136)

(include "srfi/136.sld")
