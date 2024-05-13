# /*
# =====================================================================================
# =                                                                                   =
# =   Author: Hoang Van Quyen - UET - VNU                                             =
# =                                                                                   =
# =====================================================================================
# */
import math
import timeit
t_0 = timeit.default_timer()
z = [1.0,1 ,1, 1.0, 1.231]
z_exp = [math.exp(i) for i in z]
sum_z_exp = sum(z_exp)
softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# print(softmax)
t_1 = timeit.default_timer()
elapsed_time = round((t_1 - t_0) * 10 ** 6, 3)
print(f"Elapsed time: {elapsed_time} µs")

# z = [-4.054, 0.692, -0.600, -2.409, 4.745, -2.398, -1.639, -1.515, 2.380, 3.116]

# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [-0.689, 2.528, -0.280, 1.597, -2.880, 2.958, -2.553, 4.575, 4.798, 2.597]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [4.711, 3.791, 0.179, -1.880, 3.593, 3.236, 0.383, -2.973, 1.025, -4.363]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [-2.932, -3.642, -2.649, -4.707, 4.292, -4.757, -3.893, -1.470, -1.346, 1.604]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [4.677, -4.121, 1.310, 3.715, -2.316, -3.457, 0.858, 0.862, 1.201, -4.460]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [-2.250, -3.804, -3.061, 0.387, -4.733, -1.158, -1.377, -2.251, 1.635, -4.644]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [1.387, 3.447, 2.278, 2.344, 3.714, -3.304, 3.484, 1.964, -2.548, -1.772]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [0.216, -2.216, -2.148, 4.213, -0.819, 1.973, -3.144, -1.155, 2.595, -3.641]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [2.942, 3.768, 2.131, 1.031, -0.822, -3.775, 3.814, -2.015, -4.323, -1.906]


# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
# print('\n')
# z = [0.902, 1.099, -4.948, -1.448, -0.855, -1.376, -1.797, 4.199, 4.456, -0.007]



# z_exp = [math.exp(i) for i in z]
# sum_z_exp = sum(z_exp)

# softmax = [round(i / sum_z_exp, 8) for i in z_exp]
# for i in softmax:
#     print(round(i,6))
    
    
