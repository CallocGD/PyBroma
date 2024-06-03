from setuptools import Extension, setup, find_namespace_packages
from Cython.Build import cythonize
import sys

# TODO: A Way to Automate Updates with workflows to Compiling Broma to .lib and .so would be nice...


def compilePyBroma():
    setup(
        name="pybroma",
        version="0.0.2",
        author="Calloc",
        packages=find_namespace_packages(include="pybroma*"),
        ext_modules=cythonize(
            [
                Extension(
                    "pybroma.PyBroma",
                    ["pybroma/PyBroma.pyx", "pybroma/include/Broma/src/broma.cpp"],
                    include_dirs=[
                        "pybroma/include",
                        "prbroma/include/Broma",
                        "pybroma/include/broma/include",
                        "pybroma/include/Broma/ghc",
                        "pybroma/include/Broma/PEGTL-3.2.7/include",
                        "prbroma/include/Broma/PEGTL-3.2.7/include/tao",
                        "prbroma/include/Broma/PEGTL-3.2.7/include/tao/pegtl",
                        "prbroma/include/Broma/PEGTL-3.2.7/include/tao/pegtl/internal",
                        "prbroma/include/Broma/PEGTL-3.2.7/include/tao/pegtl/contrib",
                        "pybroma/include/Broma/src",
                    ],
                    # extra_link_args=[],
                    # We need this to be /std:c++17 on windows otherwise compilation will break due to the existance of "std::variant"
                    extra_compile_args=[
                        "/O2",
                        ("/std:c++17" if sys.platform == "win32" else "--std:c++17"),
                    ],
                )
            ]
        ),
        include_package_data=True,
    )


if __name__ == "__main__":
    # We should now be able to support all platforms
    compilePyBroma()

