import math
import numpy as np

def cordic_tanh(z, n_iterations=32):
    """
    Calculates the hyperbolic tangent of z using the CORDIC algorithm.

    Args:
        z: The input value (in radians).
        n_iterations: The number of iterations to perform. More iterations
                      lead to higher accuracy.

    Returns:
        The CORDIC approximation of tanh(z).
    """
    # Pre-computed atanh(2**-i) values for i = 1, 2, ...
    # These are the angles for the hyperbolic rotations.
    atanh_table = [math.atanh(max(2.0**-i, 0.99)) for i in range(1, n_iterations + 1)]

    # The CORDIC gain for hyperbolic operations.
    # K = product of sqrt(1 - 2**(-2*i)) for i = 1 to n_iterations
    # As n increases, K approaches approximately 0.828159
    # For a fixed number of iterations, we can pre-calculate this.
    cordic_gain = 1.0
    for i in range(1, n_iterations + 1):
        cordic_gain *= math.sqrt(1 - 2.0**(-2 * i))

    # Initialize the CORDIC vectors
    # x represents cosh(z) and y represents sinh(z) after the iterations
    # We start with x=1/K and y=0, and rotate towards the target angle z.
    x = 1.0 / cordic_gain
    y = 0.0
    current_z = z

    # Perform the CORDIC iterations
    for i in range(n_iterations):
        # Determine the direction of rotation
        if current_z > 0:
            d = 1.0
        else:
            d = -1.0

        # Store the previous x value for the y update
        x_prev = x

        # Perform the hyperbolic rotation
        # This is equivalent to multiplying by the matrix:
        # [  1      d*2**-i ]
        # [ d*2**-i    1     ]
        x = x + d * y * (2.0**-(i + 1))
        y = y + d * x_prev * (2.0**-(i + 1))

        # Update the remaining angle
        current_z = current_z - d * atanh_table[i]

    # The result is y/x, which is sinh(z)/cosh(z)
    return y / x

if __name__ == '__main__':
    # --- Example Usage ---
    input_value = 1.2
    cordic_result = cordic_tanh(input_value)
    math_result = math.tanh(input_value)

    print(f"Input value: {input_value}")
    print(f"CORDIC tanh:   {cordic_result}")
    print(f"math.tanh:     {math_result}")
    print(f"Difference:    {abs(cordic_result - math_result)}")

    print("\n--- Testing a range of values ---")
    for val in np.linspace(-5, 5, 40):
        cordic_val = cordic_tanh(val)
        math_val = math.tanh(val)
        print(f"tanh({val:5.2f}): CORDIC={cordic_val: .8f}, math.tanh={math_val: .8f}, diff={abs(cordic_val - math_val):.2e}")

