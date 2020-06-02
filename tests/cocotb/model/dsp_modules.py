import numpy as np

def model(a, b):
    return a + b

if __name__ == "__main__":

    # write to binary file
    # a = np.array([5,6,7,8], dtype=np.float32)
    # a.tofile("tmp.bin")

    # read from binary file
    print(np.fromfile("tmp.bin", dtype=np.float32))