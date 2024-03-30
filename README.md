# SOFTMAX FUNCTION WITH VERILOG
### 1. Softmax
    - Softmax is an activation function and is used in the last layer in DNN
![Softmax regression model as a neural network ](illustrating%20images/soft_max_neural.png)
Figure 1: Softmax regression model as a neural network
### 2. Mathetical Model
    - Input of softmax function is real vector z = {z1...zC} with C is number of class
    - Output of softmax function is real(probability) vector a = {a1...aC} and sum of vector a is equal to 1
![Mathetical Model of Softmax function](illustrating%20images/softmax_mathetical_model.png)
Figure 2: Softmax mathetical model
### 3. Hardware Implementation Approach
    - The simplest way is to directly implement the initial softmax expression. But it has some problems.
        + Firstly: Since zi is a real number, it can lead to the value of exp(zi) becoming too large, thus consuming more resouces to store this value
        + Next: In this mathetical model, there is a division operator, which also consumes a large mount of resouces to perform
    - Improving the aforementioned problems
        + Downscaling value of exp(zi) to exp(zi - zmax) with zmax is max value of vector input z
        + Transfroming the expression for removing the division operator
![alt text](illustrating%20images/transform_model.png)
### 4. Specification
- **Block Diagram**
![block_diagram_16](illustrating%20images/16_bit/block_diagram_16.png)
- **Downscale block**
![downscale_block_16](illustrating%20images/16_bit/downscale_block_16.png)
- **Exp 1 block**
![exp_1_16](illustrating%20images/16_bit/exp_1_16.png)
- **Adder block**
![adder_block_16](illustrating%20images/16_bit/adder_block_16.png)
- **Logarith nature block**
![Logarith_block_16](illustrating%20images/16_bit/Logarith_block_16.png)
- **Subtractor 2 block**
![sub_2_block_16](illustrating%20images/16_bit/sub_2_block_16.png)
- **Exp 2 - Ouput Block**
![output_block_16](illustrating%20images/16_bit/output_block_16.png)
### 5. Simulation