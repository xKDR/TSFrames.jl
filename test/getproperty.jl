ts = TS(df_integer_index)
@test ts.data == ts[:, :data]
