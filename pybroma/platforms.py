from enum import IntFlag



class Platform(IntFlag):
	"""Special Platform Number NOTE: 
	This hasn't been merged to cython yet due to 
	compatability issues with Broma itself..."""
	NONE = 0
	Windows = 2
	iOS = 4
	Android32 = 8
	Android64 = 16
	Android = Android32 | Android64 # group for Android32 and Android64
	MacIntel = 32
	MacArm = 64
	Mac = MacIntel | MacArm
    	
def list_platforms(links:Platform) -> list[str]:
    if isinstance(links, int):
        links = Platform(links)
    link_list = []
    if links | Platform.Android:
        link_list.append("android")
    elif links | Platform.Android32:
        link_list.append("android32")
    elif links | Platform.Android:
        link_list.append("android")
    if links | Platform.Windows:
        link_list.append("win")
    if links | Platform.Mac:
        link_list.append("mac")
    elif links | Platform.MacArm:
        link_list.append("m1")
    elif links | Platform.MacIntel:
        link_list.append("imac")
    if links | Platform.Windows:
        link_list.append("windows")
    if links | Platform.iOS:
        link_list.append("ios")
    return link_list
