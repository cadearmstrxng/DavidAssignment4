# Unit tests for LQ Nash solvers.

using Assignment4
using Test: @test, @testset
using Random: seed!

seed!(0)

@testset "TestLQSolvers" begin
    # Common dynamics, costs, and initial condition.
    A = [1 0.1 0 0;
         0 1   0 0;
         0 0   1 1.1;
         0 0   0 1]
    B₁ = [0 0.1 0 0]'
    B₂ = [0 0   0 0.1]'
    dyn = Dynamics(A, [B₁, B₂])

    Q₁ = [0 0 0  0;
          0 0 0  0;
          0 0 1. 0;
          0 0 0  0]
    c₁ = Cost(Q₁)
    add_control_cost!(c₁, 1, ones(1, 1))
    add_control_cost!(c₁, 2, zeros(1, 1))

    Q₂ = [1.  0 -1 0;
          0  0 0  0;
          -1 0 1  0;
          0  0 0  0]
    c₂ = Cost(Q₂)
    add_control_cost!(c₂, 2, ones(1, 1))
    add_control_cost!(c₂, 1, zeros(1, 1))

    costs = [c₁, c₂]

    x₁ = [1., 0, 1, 0]
    horizon = 10

    # Ensure that the feedback solution satisfies Nash conditions of optimality
    # for each player, holding others' strategies fixed.
    @testset "CheckFeedbackSatisfiesNash" begin
        Ps = solve_lq_feedback(dyn, costs, horizon)
        xs, us = unroll_feedback(dyn, Ps, x₁)
        nash_costs = [evaluate(c, xs, us) for c in costs]

        # Perturb each strategy a little bit and confirm that cost only
        # increases for that player.
        ϵ = 1e-1
        for ii in 1:2
            for tt in 1:horizon
                P̃s = deepcopy(Ps)
                P̃s[ii][:, :, tt] += ϵ * randn(udim(dyn, ii), xdim(dyn))

                x̃s, ũs = unroll_feedback(dyn, P̃s, x₁)
                new_nash_costs = [evaluate(c, x̃s, ũs) for c in costs]
                @test new_nash_costs[ii] ≥ nash_costs[ii]
            end
        end
    end

#     # Ensure that the open-loop solution satisfies Nash conditions of optimality
#     # for each player, holding others' strategies fixed.
#     @testset "CheckOpenLoopSatisfiesNash" begin
#         xs, us = solve_lq_open_loop(dyn, costs, horizon, x₁)
#         nash_costs = [evaluate(c, xs, us) for c in costs]

#         # Perturb each strategy a little bit and confirm that cost only
#         # increases for that player.
#         ϵ = 1e-1
#         for ii in 1:2
#             for tt in 1:horizon
#                 ũs = deepcopy(us)
#                 ũs[ii][:, tt] += ϵ * randn(udim(dyn, ii))

#                 x̃s  = unroll_open_loop(dyn, ũs, x₁)
#                 new_nash_costs = [evaluate(c, x̃s, ũs) for c in costs]
#                 @test new_nash_costs[ii] ≥ nash_costs[ii]
#             end
#         end
#     end
end
