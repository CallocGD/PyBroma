from setuptools import Extension, setup, find_namespace_packages
from Cython.Build import cythonize
import sys

# TODO: A Way to Automate Updates with workflows to Compiling Broma to .lib and .so would be nice... 

def compilePyBroma():
    setup(
        name="pybroma",
        author="Calloc",
        py_modules=find_namespace_packages(include="pybroma*"),
        ext_modules=cythonize(
            [
                Extension(
                    "pybroma.PyBroma",
                    ["pybroma/PyBroma.pyx"],
                    extra_link_args=["pybroma/link/Broma.lib"],
                    # We need this to be /std:c++17 on windows otherwise compilation will break due to the existance of "std::variant"
                    extra_compile_args=["/std:c++17" if sys.platform == "win32" else "--std:c++17"],
                )
            ]
        ),
        include_package_data=True,        
    )

if __name__ == "__main__":
    if sys.platform != "win32":
        # I need a ".so" file first :( sorry linux/android/mac/ios users...
        raise RuntimeError("Windows is the only platform supported at the moment if you provide me a broma.so file on github we could support other platforms...")
    compilePyBroma()

