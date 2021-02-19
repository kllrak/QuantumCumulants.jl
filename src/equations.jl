"""
Abstract type for equations.
"""
abstract type AbstractEquation{LHS,RHS} end
Base.isequal(::AbstractEquation,::AbstractEquation) = false

"""
    HeisenbergEquation{LHS,RHS,H,J,R} <: AbstractEquation{LHS,RHS}
    HeisenbergEquation(lhs,rhs,H,J,rates)

Type defining a system of differential equations, where `lhs` is a vector of
derivatives and `rhs` is a vector of expressions. In addition, it keeps track
of the Hamiltonian, the collapse operators and the corresponding decay rates of
the system.

# Fields
*`lhs`: Vector of operators or averages of which the derivatives are taken.
*`rhs`: Vector of expressions to which the derivatives are equal.
*`hamiltonian`: Operator defining the system Hamiltonian.
*`jumps`: Vector of operators specifying the decay processes.
*`rates`: Decay rates corresponding to the `jumps`.

"""
mutable struct HeisenbergEquation{LHS,RHS,H,J,R} <: AbstractEquation{LHS,RHS}
    lhs::Vector{LHS}
    rhs::Vector{RHS}
    hamiltonian::H
    jumps::J
    rates::R
end
Base.hash(eq::HeisenbergEquation, h::UInt) = hash(eq.rates, hash(eq.jumps, hash(eq.hamiltonian, hash(eq.rhs, hash(eq.lhs, h)))))
Base.isequal(eq1::HeisenbergEquation,eq2::HeisenbergEquation) = isequal(hash(eq1), hash(eq2))

Base.getindex(de::HeisenbergEquation, i::Int) = HeisenbergEquation([de.lhs[i]],[de.rhs[i]],de.hamiltonian,de.jumps,de.rates)
Base.getindex(de::HeisenbergEquation, i) = HeisenbergEquation(de.lhs[i],de.rhs[i],de.hamiltonian,de.jumps,de.rates)
Base.lastindex(de::HeisenbergEquation) = lastindex(de.lhs)
Base.length(de::HeisenbergEquation) = length(de.lhs)

# Substitution
function substitute(de::HeisenbergEquation,dict)
    lhs = [substitute(l, dict) for l in de.lhs]
    rhs = [substitute(r, dict) for r in de.rhs]
    return HeisenbergEquation(lhs,rhs,de.hamiltonian,de.jumps,de.rates)
end

# Simplification
function qsimplify(de::HeisenbergEquation;kwargs...)
    lhs = [qsimplify(l;kwargs...) for l in de.lhs]
    rhs = [qsimplify(r;kwargs...) for r in de.rhs]
    return HeisenbergEquation(lhs,rhs,de.hamiltonian,de.jumps,de.rates)
end


mutable struct ScaledHeisenbergEquation{LHS,RHS,H,J,R,A,N,W} <: AbstractEquation{LHS,RHS}
    lhs::Vector{LHS}
    rhs::Vector{RHS}
    hamiltonian::H
    jumps::J
    rates::R
    scale_aons::A
    names::N
    was_scaled::W
end
Base.hash(eq::ScaledHeisenbergEquation, h::UInt) = hash(eq.was_scaled, hash(eq.names, hash(eq.scale_aons, hash(eq.rates, hash(eq.jumps, hash(eq.hamiltonian, hash(eq.rhs, hash(eq.lhs, h))))))))
Base.isequal(eq1::ScaledHeisenbergEquation,eq2::ScaledHeisenbergEquation) = isequal(hash(eq1), hash(eq2))

Base.getindex(de::ScaledHeisenbergEquation, i::Int) = ScaledHeisenbergEquation([de.lhs[i]],[de.rhs[i]],de.hamiltonian,de.jumps,de.rates,de.scale_aons,de.names,de.was_scaled[i])
Base.getindex(de::ScaledHeisenbergEquation, i) = ScaledHeisenbergEquation(de.lhs[i],de.rhs[i],de.hamiltonian,de.jumps,de.rates,de.scale_aons,de.names,de.was_scaled[i])
Base.lastindex(de::ScaledHeisenbergEquation) = lastindex(de.lhs)
Base.length(de::ScaledHeisenbergEquation) = length(de.lhs)

# Substitution
function substitute(de::ScaledHeisenbergEquation,dict)
    lhs = [substitute(l, dict) for l in de.lhs]
    rhs = [substitute(r, dict) for r in de.rhs]
    return ScaledHeisenbergEquation(lhs,rhs,de.hamiltonian,de.jumps,de.rates,de.scale_aons,de.names,de.was_scaled)
end

# Simplification
function qsimplify(de::ScaledHeisenbergEquation;kwargs...)
    lhs = [qsimplify(l;kwargs...) for l in de.lhs]
    rhs = [qsimplify(r;kwargs...) for r in de.rhs]
    return ScaledHeisenbergEquation(lhs,rhs,de.hamiltonian,de.jumps,de.rates,de.scale_aons,de.names,de.was_scaled)
end
