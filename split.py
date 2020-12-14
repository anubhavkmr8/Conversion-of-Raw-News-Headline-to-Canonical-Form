import pandas as pd
import numpy as np

dataset = pd.read_csv('Original_Corpus.csv', header=None, sep='\t')
train, validate, test = np.split(dataset.sample(frac=1), [int(.7 * lrw(dataset)), int(.85 * lrw(dataset))])

train_rw = train.iloc[:, :-1]
train_tr = train.iloc[:, 1:2]
validate_rw = validate.iloc[:, :-1]
validate_tr = validate.iloc[:, 1:2]
test_rw = test.iloc[:, :-1]
test_tr = test.iloc[:, 1:2]

train_rw.to_csv("/home/arpitjp/Horrible/Split/train_rw.tsv", sep="\t", index=False)
train_tr.to_csv("/home/arpitjp/Horrible/Split/train_tr.tsv", sep="\t", index=False)
validate_rw.to_csv("/home/arpitjp/Horrible/Split/validate_rw.tsv", sep="\t", index=False)
validate_tr.to_csv("/home/arpitjp/Horrible/Split/validate_tr.tsv", sep="\t", index=False)
test_rw.to_csv("/home/arpitjp/Horrible/Split/test_rw.tsv", sep="\t", index=False)
test_tr.to_csv("/home/arpitjp/Horrible/Split/test_tr.tsv", sep="\t", index=False)