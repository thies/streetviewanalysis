Notes and Documentation
===================

Run TF in Docker
----------------



~~~~~~~
sudo docker run -it -v $HOME/docker_tensorflow:/tf_files  gcr.io/tensorflow/tensorflow:latest-devel
cd /tensorflow
git pull

python tensorflow/examples/image_retraining/retrain.py \
--bottleneck_dir=/tf_files/bottlenecks \
--how_many_training_steps 500 \
--model_dir=/tf_files/inception \
--output_graph=/tf_files/retrained_graph.pb \
--output_labels=/tf_files/retrained_labels.txt \
--image_dir /tf_files/imageNotSuitable
~~~~~~~~~~~~~
