# Tracking Social Groups Within and Across Cameras
Groups are considered by modern sociological crowd theories the atomic entities where social processes arise and develop. To detect groups both physical and sociological cues need to be taken into account. While physical evidence is observable even at a frame-wise level, sociological aspects might need a few seconds to unfold. As a consequence, recent methods provide group detections over short temporal windows. Working with temporal windows, on the other hand, introduces a consistency problem from window to window that can be neatly formulated as a tracking problem.

The proposed solution formulates the group tracking problem as a supervised Correlation Clustering (CC) problem. Eventually, every cluster should contain all and only observation refering to the same group. A Structural SVM (SSVM) classifier is used to learn a proper similarity measure balancing the contribution of different features (HSV, SIFT, ...), leaving the algorithm with no parameters to tune. Multi-Camera group tracking is handled inside the framework by adopting an orthogonal feature encoding allowing the classifier to learn different feature weights for inter- and intra-cameras associations.

## Overview of the inference procedure
![](http://www.francescosolera.com/images/github/TCSVT_2016_github.png)

1. The image on the left pictures a few example of groups detected over short temporal windows. These groups need to be tracked both in the same camera and across cameras.
2. The image on the right models an instance of the problem: a set of group detections is observed in different cameras. For each pair of detection we can compute a correlation *W* (dashed lines) and the CC will select a subset of associations to form clusters (solid lines).

The clustering solution depends on the way correlations are defined. We let the SSVM learn a correlation score which linearly combine the contribution of different features. Details about the learning procedure can be found in the paper.

## How to run the code
It's actually pretty easy. There are a few dependencies needed by the code: ```mexopencv``` by [Kota Yamaguchi](https://github.com/kyamagu/mexopencv), ```gurobi``` optimizer [here](https://github.com/kyamagu/mexopencv) and ```vlfeat``` by [Andrea Vedaldi](http://www.vlfeat.org). Once dependecies have been installed, you can start from the ```DEMO_test.m```:

- download the code
- look for the ```DEMO_test.m``` file
- hit run!

This code will make inference on the test data and display results, features and learning is already precomputed.

Once you are familiar with the testing, you can also try to retrain the model using the same or different data/feature set. This can be done throuh ```DEMO_train.m```. As before, just hit run! If everything is fine, the training should yeld something like this:
![](http://www.francescosolera.com/images/github/TCSVT_2016_convergence_github.png)

**Visualization requires the dataset images, which will be released shortly. In the mean time you can still train/test the algorithm.**

<!-- ## How to cite
```
F. Solera, S. Calderara, R. Cucchiara
Learning to Divide and Conquer for Online Multi-Target Tracking
in Proceedings of International Converence on Computer Vision (ICCV), Santiago Cile, Dec 12-18, 2015
```
-->
