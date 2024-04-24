#include <iostream>
#include <cmath>
#include <cstdlib>
#include <time.h>
using namespace std;


void convert(double x)
{
    int exp = 0;
    int result_arr[32];
    int fraction_arr[32];
    int integer_arr[8];
    int sign_bit = 0;

    if(x < 0)
    {
        sign_bit = 1;
        x = -x;
    }
    else
        result_arr[0] = 0;

    for (int i = 0 ; i < 32 ; i ++)
        result_arr[i] = 0;
    double fraction = x - (int)x;
    int integer = int(x);
    int k = 0;
    int j = 0;
    do
    {
        integer_arr[k] = integer % 2;
        integer /= 2;
        k++;
    } while (integer != 0);

    do
    {
        fraction *= 2;
        fraction_arr[j] = (int)(fraction) % 2;
        j++;
    } while (j != 32);


    int integer_arr_temp[k];
    for (int i = 0 ; i < k ; i ++)
        integer_arr_temp[i] = integer_arr[i];



    for (int i = k - 1 ; i >= 0 ; i --)
    {
        if (integer_arr_temp[i] == 1 && k == 1)
        {
            exp += 0;
        } else if (integer_arr_temp[i] == 1)
        {
            exp += i;
            break;
        }
    }


    if (exp == 0 && integer_arr_temp[k - 1] != 1)
    {
        for (int i = 0 ; i < j ; i ++)
            if (fraction_arr[i] == 1)
            {
                exp -= i + 1;
                break;
            }
    }
    int z = 0;
    int temp_exp = exp;
        for (int i = 9 ; i < 32 ; i ++)
        {
            if (temp_exp > 0)
            {
                result_arr[i] = integer_arr_temp[exp - i + 8];
                temp_exp -= 1;
            } else if (temp_exp == 0 && z != 23)
            {
                result_arr[i] = fraction_arr[z];
                z ++;
            }
            else if (temp_exp < 0 && z != 32)
            {
                result_arr[i] = fraction_arr[z - temp_exp];
                z ++;
            }
        }

    exp = exp + 127;
    int h = 0;
    do
    {
        result_arr[8 - h] = exp % 2;
        exp /= 2;
        h++;
    } while (h != 8);
    result_arr[0] = sign_bit;
    for (int i = 0 ; i < 32 ; i ++)
    {   if (i % 4 == 0 && i != 0)
            cout << "_";
        cout <<result_arr[i];
    }

}

void softmax(float a[], int n)
{
    float exp_zi[n];
    float sum_of_exp = 0;
    for(int i = 0 ; i < n ; i ++)
    {
        exp_zi[i] = exp(a[i]);
        sum_of_exp += exp(a[i]);
    }
    float sum_of_prob = 0;
    for (int i = 0 ; i < n ; i ++)
    {
        cout << "probability's Z[" << i << "] (" << a[i] << ") = " << exp_zi[i] / sum_of_exp << "\n";
        sum_of_prob += exp_zi[i] / sum_of_exp;
    }
    cout << "sum of probability = " << sum_of_prob;
}

int main()
{

    int n = 5;
    double x;
    srand(time(0));
    float arr[n];
    float output_arr[n];
    cout << "always @(posedge axi_clock_i)\n";
    cout <<"        begin\n";
    cout << "            if (~axi_reset_n_i) begin\n";

    //cout <<"{";
    for (int i = 0 ; i < n ; i ++)
    {
        x = 100;
        do
        {
            x = (double)(rand() - 20000);
            x = x / 1000;
        }
        while (x < -5 || x > 5 || x == 0);
        arr[i] = x;
        /*
        if (i < n - 1)
            cout << x << ", ";
        if (i == n - 1)
            cout << x;
        */
        cout << "                buffer[" << i <<"] = 32'b";
        convert(x);
        cout << "                                            ;\n";
        output_arr[i] = x;
    }
    //cout << "};\n";
    cout <<"                end\n        end\n";
    softmax(arr, n);


    printf("\n%f", 0xc053126e);


    printf("\n{");
    for (int i = 0 ; i < n ; i ++)
    {
        if (i < n - 1)
            printf("%.3f, ", output_arr[i]);
        else
            printf("%.3f}", output_arr[i]);
    }
}
