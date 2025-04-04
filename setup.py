from skbuild import setup
from setuptools import find_namespace_packages

setup(
    name="pybroma",
    version="0.1.0",
    author="Calloc",
    packages=find_namespace_packages(include="pybroma*"),
    cmake_install_dir="pybroma",
    cmake_args=["-DCMAKE_BUILD_TYPE=Release"],
    include_package_data=True,
)