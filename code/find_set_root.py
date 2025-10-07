# A single utility function to find and set the project root directory
# based on the presence of specific marker files or directories.
# This allows for subsequent importing of functions from the utils module.
# E.g. from utils.functions import hello_world
# or
# import utils.functions as uf

# To use:
# from find_set_root import find_set_project_root
# PROJECT_ROOT = find_set_project_root()
# print(f"Project root found at: {PROJECT_ROOT}")

from pathlib import Path
import sys

def find_set_project_root(markers=(".git", "pyproject.toml", ".here")) -> Path:
    """
    Find the project root and add it to sys.path for relative imports.

    Parameters:
    - markers: Tuple of files/folders that indicate the root.

    Returns:
    - Path to the project root.

    Raises:
    - FileNotFoundError if no marker is found.
    """
    try:
        base = Path(__file__).resolve().parent
    except NameError:
        base = Path.cwd()

    for parent in [base] + list(base.parents):
        if any((parent / marker).exists() for marker in markers):
            root_path = str(parent)
            if root_path not in sys.path:
                sys.path.insert(0, root_path)  # Prepend for import priority
            return parent

    raise FileNotFoundError(f"❌ No marker found: {markers}")
