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
- To go beyond the scope of what broma is actually being used for.

## Cool When Pypi Release?
I'm not ready for that yet since it's difficult to configure that stuff. For now you will have to download the files and manually to setup this library since this project just got started yesterday.

# How To Install
```
python setup.py build_ext --inplace
```
I will put another command here soon that you can use this library globally
I've also only just setup windows support so sorry android, linux , macos & ios users.
However making pull requests and adding .so files might help or even an automated workflow 
to compile broma. I would apperciate if anyone does this while I'm doing other things.

Also Some parsing Error Features may not be avalible just yet so don't complain to me if it crashes
this project is not mature yet.

## Cool Will Geode Add This Library To Their Repositories?
I don't know, I doubt it but you'll just have to ask them and be paitient about it.

## Bugs
-  Platform uses the `None` Keyword Enum and this can be confusing to python users and is also uncompilable. This change is an Internal bug on broma's end and not my own fault
