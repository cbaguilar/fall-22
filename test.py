def gen(lst):
 for i in lst:
  print(f"G {i}")
  yield i//10
 print("Done!")

lst = [10,20,30]
g = gen(lst)
print("Start!")
for i in g:
  print(f"M {i}")
  if i >= 0 and i < len(lst):
    lst[i] *= -1

