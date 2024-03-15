# SOFTMAX FUNCTION WITH VERILOG
### 1. Softmax
    - Softmax is an activation function and is used in the last layer in DNN
 ![Softmax regression model as a neural network ](soft_max_neural.png)
Figure 1: Softmax regression model as a neural network
### 2. Mathetical Model
    - Input of softmax function is real vector z = {z1...zC} with C is number of class
    - Output of softmax function is real(probability) vector a = {a1...aC} and sum of vector a is equal to 1
![Mathetical Model of Softmax function](softmax_mathetical_model.png)
Figure 2: Softmax mathetical model
### 3. Hardware Implementation Approach
    - The simplest way is to directly implement the initial softmax expression. But it has some problems.
        + Firstly: Since zi is a real number, it can lead to the value of exp(zi) becoming too large, thus consuming more resouce to store this value
        + Next: In this mathetical model, there is a division operator, which also consumes a large mount of resouces to perform
    - Improving the aforementioned problems
        + Downscaling value of exp(zi) to exp(zi - zmax) with zmax is max value of vector input z
        + Transfroming the expression for removing the division operator
### 4. Specification
#### 4.1. Block diagram 
#### 4.2. Sub-Blocks
### 5. Simulation