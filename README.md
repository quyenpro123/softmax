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
![transfrom](illustrating%20images/transform_model.png)
### 4. Specification
- **Block Diagram 16 bit**
![block](illustrating%20images/16_bit/block.png)
### 5. Synthesis and Simulation result
#### 5.1 Synthesis
![synthesis result](illustrating%20images/16_bit/synthesis.png)
#### 5.2 Simulation
![simulation result](illustrating%20images/16_bit/simulation.png)
### 6. Package IP and Intergrated into SOC
#### 6.1 Package IP
![package_ip](illustrating%20images/16_bit/softmax_ip.png)
#### 6.2 Intergrated into SOC
![alt text](illustrating%20images/16_bit/SOC.png)
### 7. Result
#### 7.1 Input
- Input in Simulation
![alt text](illustrating%20images/16_bit/in_simulation.png)
- Input in ILA tool
![alt text](illustrating%20images/16_bit/in_ILA.png)
#### 7.2 Output
- Output in Simulation
![alt text](illustrating%20images/16_bit/out_simulation.png)
- Output in ILA tool
![alt text](illustrating%20images/16_bit/out_ILA.png)
###  8. Conclusion