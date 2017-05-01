import os
import tensorflow as tf
import tensorflow.python.platform
from tensorflow.python.platform import gfile
import numpy as np
import sys
import csv

image_path = sys.argv[1]
outfile = sys.argv[2]
n = int(sys.argv[3])

model_path = "/tf_files/inception/classify_image_graph_def.pb"

with gfile.FastGFile(model_path, 'rb') as f:
    graph_def = tf.GraphDef()
    graph_def.ParseFromString(f.read())
    _ = tf.import_graph_def(graph_def, name='')


# load tensor
with tf.Session() as sess:
    flattened_tensor = sess.graph.get_tensor_by_name('pool_3:0')



counter = 0
feature_dimension = 2048
features = np.empty(( n , feature_dimension))
imageIds = []
for fn in os.listdir( image_path ):
    print (fn)
    if counter == n:
        break
    else:
        # Read in the image_data
        image_data = tf.gfile.FastGFile(image_path + '/' + fn, 'rb').read()

        feature = sess.run(flattened_tensor, {
                'DecodeJpeg/contents:0': image_data
                })
        features[counter, :] = np.squeeze(feature)
        counter += 1
        print(counter)
        imageIds.append( fn )
np.save(outfile, features)

with open(outfile +".rownames.csv",'wb') as resultFile:
    #wr = csv.writer(resultFile, dialect='excel')
    #wr.writerow( imageIds )
    for x in imageIds:
        resultFile.write(str(x))
        resultFile.write("\n")
