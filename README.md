# Assignment 4: Nash equilibria of linear-quadratic (LQ) games

In this assignment, you will implement your own solvers for feedback and open-loop Nash equilibria in LQ games. By the end of this assignment you should:

- appreciate the difference (technically and intuitively) between feedback and open-loop information patterns
- internalize the dynamic programming principle and its use in LQ problems
- be confident doing linear algebra in Julia

As in previous assignments, some starter code is provided and the objective is to pass all unit tests in the `test/` directory. These tests will run automatically whenever you push a new commit. You can also check your implementation locally as described below. **Do not modify these tests in your `main` branch. If you feel you must, do so in a separate branch containing _only_ the test modifications, open a Pull Request to `main`, and add me as a reviewer so that I can approve the changes.**

## Setup

As before, this assignment is structured as a Julia package. To activate this assignment's package, type
```console
julia> ]
(@v1.6) pkg> activate .
  Activating environment at `<path to repo>/Project.toml`
(Assignment4) pkg>
```
Now exit package mode by hitting the `[delete]` key. You should see the regular Julia REPL prompt. Type:
```console
julia> using Revise
julia> using Assignment4
```
You are now ready to start working on the assignment.

## Part 0: Utilities

Check out `src/utils.jl`. Here, you'll see that I've provided a few utilities for you to use throughout the assignment. The `Cost` struct stores matrices which define a quadratic cost function for each player, and the `Dynamics` struct defines linear game dynamics (both are time-invariant). Functions to evaluate cost functions and unroll trajectories from initial conditions are provided as well.

## Part 1: Feedback

In `src/lq_feedback_solver.jl` you will find a skeleton interface for a function called `solve_lq_feedback()`. This function will compute feedback gain matrices (`P^i_t` for Player `i` at time step `t`, in the notation of Basar and Olsder, ch. 6). Implement this function following the derivation in lecture. For reference, you can refer to the derivation in Basar's book and my own typeset derivation [here](https://github.com/HJReachability/ilqgames/blob/master/derivations/feedback_lq_nash.pdf).

## Part 2: Open-loop

Similarly, in `src/lq_open_loop_solver.jl`, you will find a skeleton interface for `solve_lq_open_loop()` which returns the states and controls which form the unique Nash equilibrium in open-loop strategies. Implement this function. Again, for reference please refer to Basar's book and/or my typeset derivation [here](https://github.com/HJReachability/ilqgames/blob/master/derivations/open_loop_lq_nash.pdf).

## Part 3: Plot an example
To try out your implementation, you can use the provided script `example/coupling_example.jl` as follows in the REPL:
```console
julia> include("example/coupling_example.jl")
```

Please paste a screenshot of the plots in the conversation section of the "Feedback" PR (not to be confused with feedback Nash...).

## Autograde your work

Your work will be automatically graded every time you push a commit to GitHub. If you are not sure how to work with GitHub, I strongly recommend reading any of the short tutorial blogs available for getting up to speed, such as [this one](https://product.hubspot.com/blog/git-and-github-tutorial-for-beginners). As above: **Do not modify these tests in your `main` branch. If you feel you must, do so in a separate branch containing _only_ your test modifications, open a Pull Request to `main`, and add me as a reviewer so that I can approve the changes.**

To run tests locally and avoid polluting your commit history, in the REPL you can type:
```console
julia> ]
(Assignment4) pkg> test
```

Alternatively, you can run:
```console
julia> include("test/runtests.jl")
```

## Final note

In the auto-generated `Feedback` Pull Request, please briefly comment on (a) roughly how long this assignment took for you to complete, and (b) any specific suggestions for improving the assignment the next time the course is offered.
