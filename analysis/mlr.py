# from sklearn import linear_model
# clf = linear_model.LinearRegression()
# clf.fit([[getattr(t, 'x%d' % i) for i in range(1, 8)] for t in texts],
#         [t.y for t in texts])

texts=file("multi-linear-reg.txt").read()
print texts