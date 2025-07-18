def VeryLongFunctionNameThatDoesTooMuch():
    x = 10
    y = 20
    z = 30
    unused_variable = 100  # Unused variable
    
    for i in range(5):
        print("Iteration", i)
    
    if x == 10:
        print("x is 10")
    else:
        print("x is not 10")
    
    # Deeply nested code
    if x > 5:
        if y > 15:
            if z > 25:
                print("All conditions met")

# Calling the function
VeryLongFunctionNameThatDoesTooMuch()

def foo():
    a = 1
    b = 2
    return a + b + c  # 'c' is undefined, should cause error
