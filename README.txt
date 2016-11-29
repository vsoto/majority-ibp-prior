===============================================================
=            IB-Pruning with Hypergeometric Prior v1.0
=                                                            
= 
=  Copyright (C) 2016 Escuela Politecnica Superior, UAM
=  Authors: Victor Soto (vsoto@cs.columbia.edu)
= 	    Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
=  Colaboradores: Alberto Suarez
===============================================================

LICENSING AND REFERENCES

Please read LICENSE.txt for more information on the terms under
which this code is licensed.

If you find this code useful, please cite it as

[1] An Urn for Majority Voting in Classification Ensembles
    Victor Soto, Gonzalo Martinez-Munoz, Alberto Suarez
    NIPS 2016, Barcelona, Spain

[2] Statistical Instance-based Ensemble Pruning for Multi-class Problems
    Gonzalo Martinez-Munoz, Daniel Hernandez-Lobato, Alberto Suarez
    ICANN-2009 Limassol, Cyprus

[3] Statistical Instance-based Pruning in Ensembles of Independent Classifiers 
    Daniel Hernandez-Lobato, Gonzalo Martinez-Munoz, Alberto Suarez
    IEEE Transactions in Pattern Analysis and Machine Intelligence, 31(2), 364-369, 2009


This IB-Pruning implementation is meant to compute better lookup
tables for applying Statistical Instance-based pruning
[2,3] for ensembles of classifiers by incorporating prior
knowledge of the classification problem [1].

INSTALLATION

Add these files to the MATLAB path by right-clicking this folder
on the explorer window panel and selecting the option

"Add to path" -> "Selected folder and subfolders"


DATA FORMAT FOR TEST EXAMPLES

Each data file is formatted the same way: each row contains N 
votes for a classification example in its first N dimensions 
and its gold label in position N+1. Votes can take values in 
{0,...,num_classes - 1} for a problem with num_classes.

For example for an ensemble size of 5 for a 3-way problem the 
following row of votes would indicate that the ensemble gave two
votes to the class 0, two votes to the class 1, and one vote to the
class 2, and its real class was 0:
 
0, 1, 0, 2, 1, 0

DATA FORMAT FOR TRAIN/DEV EXAMPLES

Following the scheme presented in [3], we expect the classifiers in
the ensemble to be trained by bootstrapping the training set. Since
we use the training samples to fit the hypergeometric distribution
of the votes, only those out-of-bag votes for each example can be
used. Votes that are not out-of-bag are marked as -1 in the voting
vector, and are ignored.

For example, for an ensemble size of 5 for a 3-way problem the
following voting vector would use the  first two votes (0 and 1) and
the last two votes (2 and 1) to compute the hypergeometric
distribution. The gold class is 0.

0, 1, -1, 2 , 1, 0


INSTRUCTIONS

Run start_ibp.m to run SIBP with prior knowlege. For example, the
following call:

start_ibp(train_votes_dir, test_votes_dir, 0.99, 101, true)

would compute SIBP tables of 101 votes on 99% confidence level
including prior knowledge. The hypergeometric distribution used to
compute the SIBP tables would use the voting information contained
in the files in train_votes_dir and the performance reported would
be on the voting files of examples contained in test_votes_dir.


OUTPUT

Running

start_ibp('/local/train_data/rf/australian/', '/local/test_data/rf/australian/', 0.99, 101, true)

returns the following vector


ans =

  Columns 1 through 10

   13.0000    3.6586   13.2464    3.7928    0.8551    1.1300   62.1764    1.4492   12.7748    2.2504

  Columns 11 through 14

    5.0051    0.8211   12.9048    0.7709

where:

- Columns 1 and 2 are the average error rate and its standard
  deviation of the ensemble of 101 classifiers.
- Columns 3 and 4 are the average error rate and standard
  deviation of the SIBP-pruned ensemble using prior
  knowledge of the problem.
- Columns 5 and 6 are average and standard deviation of the
  disagreement between the full ensemble and its SIBP-pruned
  counterpart.
- Columns 7 and 8 are the average and standard deviation number
  of trees used to query an example of this problem when using
  the full ensemble of 101 classifiers. Notice this is not
  necessarily 101 because it is often possible to halt the
  querying process if more a class has received more votes than
  the remaining unaccounted votes.
- Columns 9 and 10 are the average and standard deviation number
  of trees used to query an example of this problem when using 
  the SIBP-pruned ensemble. 
- Columns 11 and 12: are the average and standard deviation of
  the speed-up rate calculated as the number of classifiers
  queried by the full ensemble divided by the number of
  classifiers queried by the pruned ensemble.
- Columns 13 and 14 are the average and standard deviation of
  the number of classifiers according to a monte-carlo simulation.


