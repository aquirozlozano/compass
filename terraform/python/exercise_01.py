# implement a sorting algorithm

srt_list = [5,2,4,6,1,3]


for j in range(len(srt_list)-2, 0, -1):
    key = srt_list[j]
    i = j + 1
    while i < len(srt_list) and srt_list[i] > key:
        srt_list[i - 1] = srt_list[i]
        i += 1
        #print(sort_this)
    srt_list[i - 1] = key

print(srt_list)