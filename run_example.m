% Run SIBP on a 101-tree ensemble with 99% confidence.
start_ibp('./labor/train/', './labor/test/', 0.99, 101, false)
% Run SIBP on a 101-tree ensemble with 99% confidence with prior.
start_ibp('./labor/train/', './labor/test/', 0.99, 101, true)

