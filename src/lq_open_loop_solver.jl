# Solve a finite horizon, discrete time LQ game to open-loop Nash equilibrium.
# Returns the trajectory of states xs[:, time] and controls us[player][:, time].
# NOTE: must provide the initial state x₁ here.
#       Why didn't we need it in the feedback case?
export solve_lq_open_loop
function solve_lq_open_loop(
    dyn::Dynamics, costs::AbstractArray{Cost}, horizon::Int, x₁)
    # TODO!
end
