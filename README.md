# LNP Model

This project uses the LNP model to fit the receptive fields of the mouse LGN interneurons.

## Project Structure

The project is structured the following way:

```
? data <- folder for the types of data that are part of the code, not those subject under analysis 
?   ?  snf <- folder for .snf (necessary for recreating the sparse noise)
? src <- where the source code lives
?   ? DataProcessing <- functions that processes / converts data into the input forms of the optimization algorithms
?   ? DataStructs <- where all the data structure classes live. 
?   ? Optimization <- functions needed for the optimizers (i.e. the loss function that computes the loss and gradient)
?   ? Validation <- functions used for validation purposes
?   ? Visualization <- visualization / plotting functions
?
? main.mlx <- mlx code that imports the actual raw recordings, processes, fits glm, and visualizes the results.
? validate_with_simulated_neuron.mlx <- imports an actual sparse noise stimulus, creates a spike train using simulate_neuron.m
?                                       and fits glm models. It is useful since you can validate whether each algorithm works
?                                       properly by comparing the fit results to the ground truth. 
? macro_glmfit.m <- macro for going through the given interneuron lists and fits glm with time-space non-separable RF 
? macro_ts_separable.m <- macro that fits glm with time and space separable RF
? macro_ts_onoff_separable.m <- macro that fits glm with two time and space separable RFs, one for on stim and off stim respectively
? validate_glmfit_results.mlx <- imports the .mat files saved from the macros, where the fitted weights and the train/test datasets
?                                are saved. the fit results can be validated through looking at the RFs, as well as the likelihood values. 
? macro_make_report.m<- auto-creates figures that has the RFs with likelihood values from the fit results.
```