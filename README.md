# PyBroma

A Python embed of [broma from geode](https://github.com/geode-sdk/broma) used to parse C++ like files from the 
[geometry dash bindings](https://github.com/geode-sdk/bindings).


## How To Use
```python
from pybroma import Root


# test.bro:
# class BindedClass {
# 	void bindedFunction() = mac 0xd5db0, win 0x3c8d, ios 0xa83bc;

# 	int m_member1;
# 	int m_member2;
# }

# class OtherBindedClass : BindedClass {
# 	virtual void otherBindedFunction() = mac 0x7e3bc, win 0x5a1c, ios 0x8e412;

# 	// win and ios addresses have not been found yet, will not generate
# 	static int staticFunction(int a, bool c) = mac 0x74bd3;

# 	// Embed c++ code
# 	inline int getIndex(int index) {
# 		return m_myVector[index];
# 	} 

# 	// templates supported
# 	std::vector<int> m_myVector;
# }

root = Root("test.bro")
for c in root.classes:
    for f in c.fields:
        # NOTE: functions that aren't a Function Bind Field do not return...
        if func := f.getAsFunctionBindField():
            # This will make a dictionary mainly to make iteration a bit easier...
            print(func.prototype.args)
# output        
# {}
# {}
# {'a': <pybroma.PyBroma.Type object at 0x0000018C6D507B70>, 'c': <pybroma.PyBroma.Type object at 0x0000018C6D507B30>}
```

## why?

- I wrote this library because it's slower to write C++ code and I felt like I needed something that could be easily aborted and easy to test when something doesn't run right.
- To use a language that I was more familliar and comfortable with and has releativly good code safety features.
- To generate code to automate the creation of mods and be able to reverse engineer geometry dash a little bit 
more efficiently. Including creating ghidra headerfiles that ghidra can understand and parse.
- For other programmers (especially beginner programmers) to try out this wonderful library that I have just recently made a bridge for in one full day. (I would expect that you have a bit of knowlege on how C++ works first.)
- To go far beyond the scope of what broma is actually being used for such as reverse engineering. 

## Cool When Pypi Release?
I may not get to that due to the required 2FA stuff because scammers were using pypi to host malicious malware.  

# How To Install
You need to clone this repository locally to install the library:
1. `git clone https://github.com/CallocGD/PyBroma.git --recursive`
2. `python setup.py build_ext --inplace`
3. `pip install -U .`

Installation using a zip archive of the repository is not available because it doesn't contain the broma submodule because of it not being in a mature state as of yet and it has been subject to constantly changing.

Also Some parsing Error Features may not be avalible just yet so don't complain to me if it crashes broma does not have a clean way to handle errors yet to my knowlege.

## Cool Will Geode Add This Library To Their Repositories?
I don't know, I sure hope so, I see the project's overall potential to be useful for that criteria but I doubt it. You'll just have to ask them and be paitient about it.

## Anything else
Might make a version of this in Rust as practice for binding C/C++ libraries since I am trying to learn how to do that kind of stuff.

## Bugs
- Did not test the new updated version yet...

## TODOS

- [X] Broma Writer/Formatter 
- [ ] Class member injector (For helping with pull requests to the bindings)
- [ ] I'm rethinking about the possiblity of a pypi release if I can find a self-hosted 2FA software thingy
