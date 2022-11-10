ts = TSFrame([random(100) random(100)])
matrix = Matrix(ts)

@test isequal(matrix[:, 1], ts[:, :x1])
@test isequal(matrix[:, 2], ts[:, :x2])