
# MODEL CREATION STEPS

## Note: - Dataset is not publically available.


Using a single script, installing libraries, tools, compiling moses, data pre-processing, training, tuning, testing models, BLEU score generation
1) Copy "moses-model23" dir present in "Final_attempt(moses)" in a UNIX like system
2) cd to "moses-model23" directory [Note: Pre-processed corpus presnt in "moses-model23/split" dir]
3) Run the following command with numerical parameter at the end describing available cores in pc
   $ sudo bash ./run-model23.sh 4
4) Transformed files for "moses-model23/split/test.rw" using Model2 (moses-pbsmt) & Model3 (moses-syntax) are produced in "moses-model23/split" directory


### In case of NETWORK RELATED ERROR while running "run-model23.sh"
1) Delete "moses-model23" from system
2) Again copy "moses-model23" dir from "Final_attempt(moses)"
3) Ensure internet connectivity and follow "MODEL CREATION STEPS" again


anubhav.kumar.eee17@itbhu.ac.in
