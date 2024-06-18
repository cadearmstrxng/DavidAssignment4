using Assignment4
using LinearAlgebra: diagm

# Script to compare open-loop and feedback solutions to a test problem involving
# coupling between two players.
# Game is described as follows:
#   - both players' dynamics are decoupled and follow double integrator motion
#     in the Cartesian plane
#   - P1 wants *P2* to get to the origin
#   - P2 wants to get close to *P1*
#   - both players want to expend minimal control effort

function coupling_example()
    # Dynamics (Euler-discretized double integrator equations with Δt = 0.1s).
    # State for each player is layed out as [x, ẋ, y, ẏ].
    Ã = [1 0.1 0 0;
     0 1   0 0;
     0 0   1 0.1;
     0 0   0 1]
    A = vcat(hcat(Ã, zeros(4, 4)), hcat(zeros(4, 4), Ã))

    B₁ = vcat([0   0;
           0.1 0;
           0   0;
           0   0.1],
          zeros(4, 2)
          )
    B₂ = vcat(zeros(4, 2),
          [0   0;
           0.1 0;
           0   0;
           0   0.1]
          )
    dyn = Dynamics(A, [B₁, B₂])

    # Costs reflecting the preferences above.
    Q₁ = zeros(8, 8)
    Q₁[5, 5] = 1.0
    Q₁[7, 7] = 1.0
    c₁ = Cost(Q₁)
    add_control_cost!(c₁, 1, 0.1 * diagm([1, 1]))

    Q₂ = zeros(8, 8)
    Q₂[1, 1] = 1.0
    Q₂[5, 5] = 1.0
    Q₂[1, 5] = -1.0
    Q₂[5, 1] = -1.0
    Q₂[3, 3] = 1.0
    Q₂[7, 7] = 1.0
    Q₂[3, 7] = -1.0
    Q₂[7, 3] = -1.0
    c₂ = Cost(Q₂)
    add_control_cost!(c₂, 2, 0.1 * diagm([1, 1]))

    costs = [c₁, c₂]

    # Initial condition chosen randomly. Ensure both have relatively low speed.
    x₁ = randn(8)
    x₁[[2, 4, 6, 8]] .= 0

    # Solve over a horizon of 100 timesteps.
    horizon = 50

    Ps = solve_lq_feedback(dyn, costs, horizon)
    xs_feedback, us_feedback = unroll_feedback(dyn, Ps, x₁)
    xs_open_loop, us_open_loop = solve_lq_open_loop(dyn, costs, horizon, x₁)

    return xs_feedback, us_feedback, xs_open_loop, us_open_loop
end

# Call this fn.
xs_feedback, us_feedback, xs_open_loop, us_open_loop = coupling_example()
horizon = last(size(xs_feedback))

# Plot.
using ElectronDisplay
using Plots

p = plot(legend=:outertopright)

# Feedback.
α = 0.2
plot!(p, xs_feedback[1, :], xs_feedback[3, :],
      seriestype=:scatter, arrow=true, seriescolor=:blue, label="P1 feedback")
plot!(p, xs_feedback[1, :], xs_feedback[3, :],
      seriestype=:quiver,  seriescolor=:blue,
      quiver=(0.1 * xs_feedback[2, :], 0.1 * xs_feedback[4, :]),
      seriesalpha=α,
      label="P1 vel (FB)")
plot!(p, xs_feedback[1, :], xs_feedback[3, :],
      seriestype=:quiver,  seriescolor=:turquoise,
      quiver=(0.1 * us_feedback[1][1, :], 0.1 * us_feedback[1][2, :]),
      seriesalpha=α,
      label="P1 acc (FB)")

plot!(p, xs_feedback[5, :], xs_feedback[7, :],
      seriestype=:scatter, arrow=true, seriescolor=:red, label="P2 feedback")
plot!(p, xs_feedback[5, :], xs_feedback[7, :],
      seriestype=:quiver,  seriescolor=:red,
      quiver=(0.1 * xs_feedback[6, :], 0.1 * xs_feedback[8, :]),
      seriesalpha=α,
      label="P2 vel (FB)")
plot!(p, xs_feedback[5, :], xs_feedback[7, :],
      seriestype=:quiver,  seriescolor=:pink,
      quiver=(0.1 * us_feedback[2][1, :], 0.1 * us_feedback[2][2, :]),
      seriesalpha=α,
      label="P2 acc (FB)")

# Open loop.
plot!(p, xs_open_loop[5, :], xs_open_loop[7, :],
      seriestype=:scatter, arrow=true, seriescolor=:purple, label="P2 open-loop")
plot!(p, xs_open_loop[5, :], xs_open_loop[7, :],
      seriestype=:quiver,  seriescolor=:purple,
      quiver=(0.1 * xs_open_loop[6, :], 0.1 * xs_open_loop[8, :]),
      seriesalpha=α,
      label="P2 vel (OL)")
plot!(p, xs_open_loop[5, :], xs_open_loop[7, :],
      seriestype=:quiver,  seriescolor=:magenta,
      quiver=(0.1 * us_open_loop[2][1, :], 0.1 * us_open_loop[2][2, :]),
      seriesalpha=α,
      label="P2 acc (OL)")

plot!(p, xs_open_loop[1, :], xs_open_loop[3, :],
      seriestype=:scatter, arrow=true, seriescolor=:green, label="P1 open-loop")
plot!(p, xs_open_loop[1, :], xs_open_loop[3, :],
      seriestype=:quiver,  seriescolor=:green,
      quiver=(0.1 * xs_open_loop[2, :], 0.1 * xs_open_loop[4, :]),
      seriesalpha=α,
      label="P1 vel (OL)")
plot!(p, xs_open_loop[1, :], xs_open_loop[3, :],
      seriestype=:quiver,  seriescolor=:lightgreen,
      quiver=(0.1 * us_open_loop[1][1, :], 0.1 * us_open_loop[1][2, :]),
      seriesalpha=α,
      label="P1 acc (OL)")

display(p)
