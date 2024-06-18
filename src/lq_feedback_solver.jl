# Solve a finite horizon, discrete time LQ game to feedback Nash equilibrium.
# Returns feedback matrices P[player][:, :, time]
export solve_lq_feedback
function solve_lq_feedback(
    dyn::Dynamics, costs::AbstractArray{Cost}, horizon::Int)
    # TODO!
    Ps = [zeros(udim(dyn,1), xdim(dyn),horizon+1)]
    for i in 2:length(costs)
        push!(Ps,zeros(udim(dyn,i), xdim(dyn),horizon+1))
    end

    αs = Matrix{Vector{Float64}}(undef, length(costs), horizon+1)

    Zs = Matrix{Matrix{Float64}}(undef, length(costs), horizon+1)
    ζs = Matrix{Vector{Float64}}(undef, length(costs), horizon+1)
    ns = Matrix{Float64}(undef, length(costs), horizon+1)

    βs = Vector{Vector{Float64}}(undef, horizon)
    Fs = Vector{Matrix{Float64}}(undef, horizon)

    # Initialize Final Times
    for ii in 1:length(costs)

        for tt in 1:horizon+1
            αs[ii,tt] = zeros(udim(dyn,ii))
        end
        Zs[ii,horizon+1] = zeros((xdim(dyn), xdim(dyn)))

        
        ζs[ii,horizon+1] = zeros(xdim(dyn))
        ns[ii,horizon+1] = 0
    end

    

    maxiter = 100
    convTol = 1e-3
    A = dyn.A
    Bs = dyn.Bs

    # Backward Pass
    for tt in horizon:-1:1
        # iterate to better P approximations
        #while not converged on P,
        iter = 0
        while iter < maxiter
            iter += 1
            Fs[tt] = A - sum([Bs[i] * Ps[i][:,:,tt] for i in 1:length(costs)])
            βs[tt] = - sum([Bs[i] * αs[i,tt] for i in 1:length(costs)])

            for player in eachindex(costs)
                Zs[player, tt] = costs[player].Q + sum([Ps[i][:,:,tt]' * costs[player].Rs[i] * Ps[i][:,:,tt] for i in eachindex(costs)]) + Fs[tt]'*Zs[player, tt+1]*Fs[tt]
                ζs[player, tt] = sum([Ps[i][:,:, tt]' * costs[player].Rs[i] * αs[i, tt] for i in 1:length(costs)]) + Fs[tt]'*ζs[player, tt+1] + Fs[tt]'*Zs[player, tt+1]*βs[tt]
                ns[player, tt] = 1/2 * ( sum([αs[i, tt]' * costs[player].Rs[i] * αs[i, tt] for i in 1:length(costs)]) - (2*ζs[player, tt+1] - Zs[player, tt+1] * sum([Bs[i] * αs[i, tt] for i in 1:length(costs)]) )' * sum([Bs[i] * αs[i, tt] for i in 1:length(costs)])) + ns[player, tt+1]

                # calculate P, α from equation 10,11

                Ps[player][:,:,tt] = inv(costs[player].Rs[player]) * (Bs[player]' * Zs[player, tt+1] * A - Bs[player]' * Zs[player, tt+1] * sum([Bs[i] * Ps[i][:,:,tt] for i in 1:length(costs)]))
                αs[player, tt] = inv(costs[player].Rs[player]) * (Bs[player]' * ζs[player, tt+1] - Bs[player]' * Zs[player, tt+1] * sum([Bs[i] * αs[i, tt] for i in 1:length(costs)]))
 
            end
        end

    end

    P = [[],[]]
    for i in eachindex(P)
        for j in 1:horizon
            push!(P[i], Ps[i][:,:,j])
        end
    end

    return P

end
