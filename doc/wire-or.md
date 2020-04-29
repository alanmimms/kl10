# Wire-OR for negative logic signals

    | I1  | I2  | !I1 | !I2 | O   |  !O |
    | --- | --- | --- | --- | --- | --- |
    |  0  |  0  |  1  |  1  | 1   |  0  |
    |  0  |  1  |  1  |  0  | 1   |  0  |
    |  1  |  0  |  0  |  1  | 1   |  0  |
    |  1  |  1  |  0  |  0  | 0   |  1  |

## CONCLUSION

WIRE-OR of negative logic signals should be treated as AND of the
positive logic inputs for positive logic output!
