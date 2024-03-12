from .PyBroma import *
from enum import IntEnum 

class Platform(IntEnum):
	"""Special Platform Number NOTE: 
	  This hasn't been merged to cython yet due to 
	  there being compatability issues with Broma 
    itself because it has a flag called "None" which 
    Violates Python's rules for enum names...
  """
	NONE = 0
	Mac = 1
	Windows = 2
	Android = 4
	iOS = 8
	Android32 = 16
	Android64 = 32
