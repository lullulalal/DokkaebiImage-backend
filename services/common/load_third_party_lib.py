import ctypes
import os
import platform

FUNC_SIGNATURES = {
    "run_bm3d_yuv_memory": {
        "argtypes": [
            ctypes.POINTER(ctypes.c_ubyte),
            ctypes.POINTER(ctypes.c_ubyte),
            ctypes.c_int, ctypes.c_int, ctypes.c_int
        ],
        "restype": ctypes.c_int
    },
}

def load_third_party_lib(algo_name: str, func_name: str):

    if platform.system() == "Windows":
        lib_filename = f"nr_lib{algo_name}.dll"
    else:
        lib_filename = f"nr_lib{algo_name}.so"

    lib_path = os.path.join("services", "3rd_party_libs", lib_filename)

    if not os.path.exists(lib_path):
        raise FileNotFoundError(f"Library file not found: {lib_path}")

    lib = ctypes.CDLL(lib_path)

    if not hasattr(lib, func_name):
        raise AttributeError(f"Function '{func_name}' not found in {lib_filename}")

    func = getattr(lib, func_name)

    if func_name in FUNC_SIGNATURES:
        sig = FUNC_SIGNATURES[func_name]
        func.argtypes = sig["argtypes"]
        func.restype = sig["restype"]
    else:
        raise ValueError(f"No signature defined for function '{func_name}'")

    return func
