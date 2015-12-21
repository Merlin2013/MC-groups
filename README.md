# Tracking Social Groups Within and Across Cameras
Groups are considered by modern sociological crowd theories the atomic entities where social processes arise and develop. To detect groups both physical and sociological cues need to be taken into account. While physical evidence is observable even at a frame-wise level, sociological aspects might need a few seconds to unfold. As a consequence, recent methods provide group detections over short temporal windows. Working with temporal windows, on the other hand, introduces a consistency problem from window to window that can be neatly formulated as a tracking problem.

The proposed solution formulates the group tracking problem as a supervised Correlation Clustering (CC) problem. Eventually, every cluster should contain all and only observation refering to the same group. A Structural SVM (SSVM) classifier is used to learn a proper similarity measure balancing the contribution of different features (HSV, SIFT, ...), leaving the algorithm with no parameters to tune. Multi-Camera group tracking is handled inside the framework by adopting an orthogonal feature encoding allowing the classifier to learn different feature weights for inter- and intra-cameras associations.

## Overview of the inference procedure
![](http://www.francescosolera.com/images/github/TCSVT_2016_github.png)

1. The image on the left pictures a few example of groups detected over short temporal windows. These groups need to be tracked both in the same camera and across cameras.
2. The image on the right models an instance of the problem: a set of group detections is observed in different cameras. For each pair of detection we can compute a correlation *W* (dashed lines) and the CC will select a subset of associations to form clusters (solid lines).

The clustering solution depends on the way correlations are defined. We let the SSVM learn a correlation score which linearly combine the contribution of different features. Details about the learning procedure can be found in the paper.

## How to run the code
It's actually pretty easy:
- download the code
- look for the DEMO.m file
- hit run!

To ease your first encounter with the code, standard data is provided if you clone this branch. The code first runs over a learning stage on PETS09-S2-L1 where it takes the groundtruth, it *degrades* it to mimic detection errors or association complexities and finds out the best parameter set.

Once the learning is done, the method will move on to testing the learnt model. Besides PETS09-S2-L1, you can also try to run the code on PETS09-S2-L2 or new datasets. In that case, just copy the directory structure of the included datasets. Have fun!

## How to cite
```
F. Solera, S. Calderara, R. Cucchiara
Learning to Divide and Conquer for Online Multi-Target Tracking
in Proceedings of International Converence on Computer Vision (ICCV), Santiago Cile, Dec 12-18, 2015
```
