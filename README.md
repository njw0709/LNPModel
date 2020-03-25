# LNP Model

This project uses the LNP model to fit the receptive fields of the mouse LGN interneurons.

## Project Structure

The project is structured the following way:

```
|- data <- folder for the types of data that are part of the code, not those subject under analysis
|   |
|   |- snf <- folder for .snf (necessary for recreating the sparse noise)
|
|- src <- where the source code lives
|   |
|   |- DataProcessing <- functions that processes / converts data into the input forms of the optimization algorithms
|   |
|   |- DataStructs <- where all the data structure classes live. 
|   |
|   |- Optimization <- functions needed for the optimizers (i.e. the loss function that computes the loss and gradient)
|   |
|   |- Validation <- functions used for validation purposes
|   |
|   |- Visualization <- visualization / plotting functions
|
|- main.mlx <- mlx code that imports the actual raw recordings, processes, fits glm, and visualizes the results.
|
|- validate_with_simulated_neuron.mlx <- imports an actual sparse noise stimulus, creates a spike train using simulate_neuron.m
|                                       and fits glm models. It is useful since you can validate whether each algorithm works
|                                       properly by comparing the fit results to the ground truth. 
|
|- macro_glmfit.m <- macro for going through the given interneuron lists and fits glm with time-space non-separable RF 
|
|- macro_ts_separable.m <- macro that fits glm with time and space separable RF
|
|- macro_ts_onoff_separable.m <- macro that fits glm with two time and space separable RFs, one for on stim and off stim respectively
|
|- validate_glmfit_results.mlx <- imports the .mat files saved from the macros, where the fitted weights and the train/test datasets
|                                are saved. the fit results can be validated through looking at the RFs, as well as the likelihood values. 
|
|- macro_make_report.m <- auto-creates figures that has the RFs with likelihood values from the fit results.
```

** A step-by-step guide for understanding ```neg_log_likli_poisson.m``` and ```make_design_matrix.m``` can be found in *.pdf

## Future Directions / Questions

1. Train/test data division

There are things that can be done differently for dividing the train and test datasets:

- Currently, the data gets randomly mixed before it gets divided into train / test datasets. Since there are multiple repetition of
the same stimulus in a single sparse noise recording, we can turn off the random mixing and just cut-off the last repetition.
This may prevent the overfitting problem we observe in the results.

- Maybe concatenating multiple recordings will work better? We can turn one recording into the train set and another into the test set.
We may need to account for the change in the size of the boxes (the multiplier values) when we are concatenating two recordings though.

2. Optimization

- How do you prevent overfitting? We can test with methods mentioned above, or do some sort of early-termination if possible.

- We can potentially add a sparseness term (L1 on the second derivative of the temporal rf, and just the values of the spatial rf)
 in addition to the neg-log-likelihood loss. This is more complicated since we need to optimize how much weight is put on
 the L1 term.

- For on/off separable case, can you constrain each spatial rf to have only positive and negative values respectively?
This can be done pretty easily using `fmincon` instead of `fminunc`, but optimization becomes extremely slow. However, observations on the 
resulting on/off spatial rfs optimized with `fminunc` and on/off separated stimuli seem to suggest that 
the on or off spatial rfs rarely have negative or positive values respectively.